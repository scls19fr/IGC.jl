const DEFAULT_SOURCE = 'F'
const EOL_DEFAULT = "\n"
const TZ = tz"UTC"
const DEFAULT_STORE_ALL_RECORDS = false

const SINGLE_INSTANCE_DATA_RECORDS_CHARS = Set(['A', 'H', 'I', 'J', 'C', 'D', 'G'])
const MULTIPLE_INSTANCE_DATA_RECORDS_CHARS = Set(['B', 'E', 'F', 'K', 'L'])
const DATA_RECORDS_CHARS = union(SINGLE_INSTANCE_DATA_RECORDS_CHARS, MULTIPLE_INSTANCE_DATA_RECORDS_CHARS)

module FixValidity
    @enum FixValidityEnum begin
        Fix3D = Int('A')  # 3D fix
        Fix2D = Int('V')  # 2D fix (no GNSS altitude) or for no GNSS data (pressure altitude data)
    end

    const ALLOWED = Set(Char(Int(fix)) for fix in instances(FixValidityEnum))

    function parse(val::Char)
        val ∉ ALLOWED && throw(ArgumentError("Invalid fix validity $(repr(val)). It can only be in $(repr(ALLOWED))"))
        return FixValidityEnum(Int(val))
    end

    function string(fv::FixValidityEnum)
        return "$(Char(Integer(fv)))"
    end

    function write(stream::IO, fv::FixValidityEnum)
        Base.write(stream, string(fv))
    end
end

module GpsQualifier
    @enum GpsQualifierEnum begin
        GPS = 1
        DGPS = 2
    end

    const ALLOWED = Set(Int(fix) for fix in instances(GpsQualifierEnum))

    function decode(val)
        val ∉ ALLOWED && throw(ArgumentError("Invalid GPS qualifier $(repr(val)). It can only be in $(repr(ALLOWED))"))
        return GpsQualifierEnum(val)
    end

    function parse(val::Char)
        return decode(Base.parse(Int64, val))
    end

    function string(qualifier::GpsQualifierEnum)
        return "$(Integer(qualifier))"
    end

    function write(stream::IO, qualifier::GpsQualifierEnum)
        Base.write(stream, "$(string(qualifier))")
    end
end


# ===

module ParsingMode
    @enum(ParsingModeEnum, STRICT, UNSTRICT)
    
    const DEFAULT = UNSTRICT
end
