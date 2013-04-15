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
         return {type='d'}
      elseif char == 'C' or char == 'c' then
         return {type='c'}
      elseif char == 'R' or char == 'r' then
         return {type='print', c='\n'}
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

function main(desc)
   dump(parse(desc))
end

if arg[1] then
   main(io.open(arg[1]))
else
   main(io.stdin)
end
