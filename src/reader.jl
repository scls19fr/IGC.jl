import Base: parse

# ========================================

function parse(::Type{IGCTime}, s::String)
    return IGCTime(Time(s, IGC_TIME_FMT))
end

function parse(::Type{IGCDate}, s::String)
    m = match(DATE_PATTERN, s)
    day = parse(Int, m[1])
    month = parse(Int, m[2])
    year = parse(Int, m[3])
    year = 2000 + year
    return IGCDate(Date(year, month, day))
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

# ========================================

function parse(::Type{A_record}, line::String)
    @assert line[1] == 'A'
    id_addition = length(line) == 7 ? "" : strip(line[8:end])
    return A_record(line[2:4], line[5:7], id_addition)
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

function parse(::Type{Abstract_C_record}, line::String)
    @assert line[1] == 'C'

    istaskinfo = isdigit(line[9])

    if istaskinfo
        return C_record_task_info(
            parse(IGCDate, line[2:7]),
            parse(IGCTime, line[8:13]),
            parse(IGCDate, line[14:19]),
            line[20:23],
            parse(Int64, line[24:25]),
            strip(line[26:end])
        )
    else
        return C_record_waypoint_info(
            parse(IGCLatitude, line[2:9]),
            parse(IGCLongitude, line[10:18]),
            strip(line[19:end])
        )
    end
end

# ========================================

module ParsingMode
    @enum(ParsingModeEnum, STRICT, UNSTRICT)
    
    const DEFAULT = UNSTRICT
end

function read_igc_file(fname; parsing_mode=ParsingMode.DEFAULT)
    stream = open(fname)
    return parse_igc(stream, parsing_mode=parsing_mode)
end

function parse_igc(s; parsing_mode=ParsingMode.DEFAULT)
    stream = IOBuffer(s)
    return parse_igc(stream::IO, parsing_mode=parsing_mode)
end

function parse_igc(stream::IO; parsing_mode=ParsingMode.DEFAULT)
    igcdoc = IGCDocument()
    for (line_id, line) in enumerate(eachline(stream))
        if line[1] == 'B'
            rec = parse(B_record, string(line))
            push!(igcdoc.B_records, rec)
        else
            exc = IGCParseException(line_id, line)
            if parsing_mode == ParsingMode.UNSTRICT
                push!(igcdoc.errors, exc)
            else
                throw(exc)
            end
        end
    end
    return igcdoc
end
