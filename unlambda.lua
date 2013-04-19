-- Warning: The primitives of the Unlambda interpreter are curried and
-- written in Continuation Passing Style to accommodate Unlambda's 'c'
-- primitive. If you haven't seen code written like this before, don't
-- hate me, usually you'd have the machine do the converting for you.

function k (x, cont)
   local function inner (y, cont)
      return cont(x)
   end
   return cont(inner)
end

-- this procedure is quite disgusting, c'est la vie
function s (f, cont)
   local function inner (g, cont)
      local function inner2 (x, cont)
         local function fcont(f)
            local function gcont(a)
               return f(a, cont)
            end
            return g(x, gcont)
         end
         return f(x, fcont);
      end
      return cont(inner2)
   end
   return cont(inner)
end

function i (x, cont)
   return cont(x)
end

function void (x, cont)
   return cont(v)
end

function callcc (f, cont)
   local function inner (x, cont2)
      return cont(x)
   end
   return f(inner, cont)
end

function display (c)
   local function inner(x, cont)
      io.write(c)
      return cont(x)
   end
   return inner
end

function delay(expr, cont)
   function new(arg,cont)
      function econt (f)
         return f(arg,cont)
      end
      return eval(expr, econt)
   end
   return cont(new)
end

-- Interpreter

function evapply(f, a, cont)
   local function fcont(fval)
      local function acont(aval)
         return fval(aval, cont)
      end
      if type(fval) == 'function' then
         return eval(a, acont);
      elseif type(fval) == 'table' and fval.type == 'delay' then
         return delay(a,cont);
      else
         error()
      end
   end
   return eval(f, fcont)
end

function eval(tree, cont)
   if tree.type == 'apply' then
      return evapply(tree.func, tree.arg, cont);
   elseif tree.type == 's' then
      return cont(s);
   elseif tree.type == 'k' then
      return cont(k);
   elseif tree.type == 'i' then
      return cont(i);
   elseif tree.type == 'v' then
      return cont(void)
   elseif tree.type == 'print' then
      return cont(display(tree.c));
   elseif tree.type == 'delay' then
      return cont(tree);
   elseif tree.type == 'c' then
      return cont(callcc);
   else
      error()
   end
end

function parse(file)
   while true do
      local char = file:read(1)
      if not char then
         error()
      elseif char == 'S' or char == 's' then
         return {type='s'}
      elseif char == 'K' or char == 'k' then
         return {type='k'}
      elseif char == 'I' or char == 'i' then
         return {type='i'}
      elseif char == '`' then
         local f = parse(file)
         local a = parse(file)
         return {type='apply', func=f, arg=a}
      elseif char == 'V' or char == 'v' then
         return {type='v'}
      elseif char == '.' then
         local next = file:read(1)
         if next then
            return {type='print', c=next}
         else
            error()
         end
      elseif char == 'D' or char == 'd' then
         return {type='delay'}
      elseif char == 'C' or char == 'c' then
         return {type='c'}
      elseif char == 'R' or char == 'r' then
         return {type='print', c='\n'}
      elseif char == '#' then
         file:read("*l")
      end
   end
end

function dump(tree)
   if tree.type == 'apply' then
      io.write("{type=apply, func=")
      dump(tree.func)
      io.write(", arg=")
      dump(tree.arg)
      io.write("}")
   elseif tree.type == 'print' then
      io.write(string.format("{type=print, c=%q}", tree.c))
   else
      io.write("{type=",tree.type,"}")
   end
end

function id(x)
   return x
end

function main(desc)
   --dump(parse(desc))
   eval(parse(desc),id)
end

if arg[1] then
   main(io.open(arg[1]))
else
   main(io.stdin)
end
