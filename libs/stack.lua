local insert, remove = table.insert, table.remove

function stack()
    return {}
end

function stackclear( stack )
    stack = {}
    collectgarbage()
end

function stacklast( stack, item )
    return stack[#stack]
end

function push( stack, item )
    insert(stack, item)
end

function pop( stack )
    return remove( stack )
end
