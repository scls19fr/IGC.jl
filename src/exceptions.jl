import Base: showerror

struct IGCParseException <: Exception
    line_id::Int
    line::String
end
IGCParseException(line; line_id=-1) = IGCParseException(line_id, line)

function showerror(io::IO, e::IGCParseException)
    msg = "can't parse"
    if e.line_id > 0
        msg *= " line $(e.line_id)"
    end
    msg *= " \"$(e.line)\""
    print(io, msg)
end
