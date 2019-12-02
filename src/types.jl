struct IGCDate
    val::Date
end
IGCDate(y, m, d) = IGCDate(Date(y, m, d))

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


struct IGCDocument
    B_records::Vector{B_record}
    errors::Vector{IGCParseException}
end
IGCDocument() = IGCDocument(B_record[], IGCParseException[])
