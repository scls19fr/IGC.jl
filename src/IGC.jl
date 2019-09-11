module IGC

using Dates
using TimeZones
using TimeZones: ZonedDateTime
import Base: parse, read, write, string, isempty

export IGCDocument, Abstract_IGC_record

include("formats.jl")
include("patterns.jl")
include("constants.jl")
include("exceptions.jl")
include("tlc.jl")
include("types.jl")
include("filename.jl")
include("reader.jl")
include("writer.jl")

end # module
