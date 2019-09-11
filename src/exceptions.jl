import Base: showerror

struct IGCParseException <: Exception
    line_id::Int
    line::String
    e::Exception
end
IGCParseException(line, e; line_id=-1) = IGCParseException(line_id, line, e)

function showerror(io::IO, e::IGCParseException)
    msg = "Can't parse"
    if e.line_id > 0
        msg *= " line $(e.line_id)"
    end
    msg *= " \"$(e.line)\""
    print(io, msg)
    # print(io, " ")
    # print(io, e.e)
    throw(e.e)
end

struct IGCWriteException <: Exception
    msg::String
end

struct IGCNonUniqueRecordException <: Exception
    msg::String
end
