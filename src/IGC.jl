module IGC

import Base: parse
using Dates

const IGC_TIME_FMT = "HHMMSS"


struct IGCDate
    val::Date
end
IGCDate(y, m, d) = new(Date(y, m, d))

struct IGCTime
    val::Time
end
IGCTime(h, mi, s) = IGCTime(Dates.Time(h, mi, s))

struct IGCLatitude
    val::Float64
end

struct IGCLongitude
    val::Float64
end

abstract type AbstractIGCAltitude end

struct IGCPressureAltitude <: AbstractIGCAltitude
    val::Int64
end

struct IGCGpsAltitude <: AbstractIGCAltitude
    val::Int64
end

const ALLOWED_FIX_VALIDITY = ('A', 'V')

struct IGCFixValidity
    val::Char

    function IGCFixValidity(val::Char)
        val ∉ ALLOWED_FIX_VALIDITY && throw(ArgumentError("Invalid fix validity $(repr(val)) but it can only be in $(repr(ALLOWED_FIX_VALIDITY))"))
        new(val)
    end
end

abstract type Abstract_IGC_Record end

struct A_record <: Abstract_IGC_Record
    manufacturer::String
    id::String
    id_addition::String
end

function parse(::Type{A_record}, line::String)
    @assert line[1] == 'A'
    id_addition = length(line) == 7 ? "" : strip(line[8:end])
    return A_record(line[2:4], line[5:7], id_addition)
end

struct B_record <: Abstract_IGC_Record
    time::IGCTime
    lat::IGCLatitude
    lon::IGCLongitude
    validity::IGCFixValidity
    pressure_alt::IGCPressureAltitude
    gps_alt::IGCGpsAltitude
    start_index_extensions::Int64
    extensions_string::String
end

function parse(::Type{B_record}, line::String)
    @assert line[1] == 'B'

    return B_record(
        parse(IGCTime, line[2:7]),
        parse(IGCLatitude, line[8:15]),
        parse(IGCLongitude, line[16:24]),
        IGCFixValidity(line[25]),
        parse(IGCPressureAltitude, line[26:30]),
        parse(IGCGpsAltitude, line[31:35]),
        35,
        strip(line[36:end])
    )
end

function parse(::Type{IGCTime}, s::String)
    return IGCTime(Time(s, IGC_TIME_FMT))
end

function parse(::Type{IGCDate}, s::String)
    return IGCDate(Date(2000 + parse(Int, s[5:6]), parse(Int, s[3:4]), parse(Int, s[1:2])))
end

function parse(::Type{IGCLatitude}, s::String)
    d = parse(Int64, s[1:2])
    m = parse(Float64, s[3:7]) / 1000.
    ordinal = s[8]

    latitude = d + m / 60.

    if !(0. <= latitude <= 90.)
        throw(ArgumentError("Invalid latitude format $(repr(s)) - range error"))
    end

    if ordinal ∉ ('S', 'N')
        throw(ArgumentError("Invalid latitude format $(repr(s)) - ordinal error"))
    end

    if ordinal == 'S'
        latitude = -latitude
    end

    return IGCLatitude(latitude)
end

function parse(::Type{IGCLongitude}, s::String)
    d = parse(Float64, s[1:3])
    m = parse(Float64, s[4:8]) / 1000.
    ordinal = s[9]

    longitude = d + m / 60.

    if !(0. <= longitude <= 180.)
        throw(ArgumentError("Invalid longitude format $(repr(s)) - range error"))
    end

    if ordinal ∉ ('W', 'E')
        throw(ArgumentError("Invalid longitude format $(repr(s)) - ordinal error"))
    end

    if ordinal == 'W'
        longitude = -longitude
    end

    return IGCLongitude(longitude)
end

function parse(::Type{IGCPressureAltitude}, s::String)
    return IGCPressureAltitude(parse(Int, s))
end

function parse(::Type{IGCGpsAltitude}, s::String)
    return IGCGpsAltitude(parse(Int, s))
end

end # module
