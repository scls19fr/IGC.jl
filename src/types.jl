abstract type IGCData end

EmptyDate() = Date(0, 1, 1)
EmptyTime() = Time(0, 0, 0)

struct IGCLatitude <: IGCData
    value::Float64
end

struct IGCLongitude <: IGCData
    value::Float64
end

abstract type AbstractIGCAltitude <: IGCData end

struct IGCPressureAltitude <: AbstractIGCAltitude
    value::Int64
end

struct IGCGpsAltitude <: AbstractIGCAltitude
    value::Int64
end

struct IGCFixValidity
    value::Char
end

# ========================================

abstract type Abstract_IGC_record end

# ========================================

struct IGCExtension
    bytes::UnitRange{Int64}
    type::String
end

abstract type AbstractExtensionsRecord <: Abstract_IGC_record end

struct I_record <: AbstractExtensionsRecord
    extensions::Vector{IGCExtension}
end
I_record() = I_record(IGCExtension[])

struct J_record <: AbstractExtensionsRecord
    extensions::Vector{IGCExtension}
end
J_record() = J_record(IGCExtension[])

# ========================================

mutable struct A_record <: Abstract_IGC_record
    manufacturer::String
    id::String
    id_addition::String
end
A_record() = A_record("", "", "")
function isempty(rec::A_record)
    return (length(rec.manufacturer) + length(rec.id) + length(rec.id_addition)) == 0
end

struct B_record <: Abstract_IGC_record
    time::Time
    latitude::IGCLatitude
    longitude::IGCLongitude
    validity::FixValidity.FixValidityEnum
    pressure_alt::IGCPressureAltitude
    gps_alt::IGCGpsAltitude
    start_index_extensions::Int64
    extensions_string::String
    extensions::Vector{IGCExtension}
end
function B_record(time, lat, lon, validity, pressure_alt, gps_alt, start_index_extensions, extensions_string; extensions=Vector{IGCExtension}())
    return B_record(time, lat, lon, validity, pressure_alt, gps_alt, start_index_extensions, extensions_string, extensions)
end


abstract type Abstract_C_record <: Abstract_IGC_record end

struct DeclarationInstant
    date::Date
    time::Time
end
DeclarationInstant() = DeclarationInstant(EmptyDate(), EmptyTime())
ZonedDateTime(dt::DeclarationInstant, tz) = ZonedDateTime(dt.date + dt.time, tz)

struct C_record_task_info <: Abstract_C_record
    declaration::DeclarationInstant
    flight_date::Date
    number::String
    num_turnpoints::Int64
    description::String
end
C_record_task_info(declaration_date, declaration_time, flight_date, number, num_turnpoints, description) = C_record_task_info(DeclarationInstant(declaration_date, declaration_time), flight_date, number, num_turnpoints, description)
C_record_task_info() = C_record_task_info(DeclarationInstant(), EmptyDate(), "", 0, "")

struct C_record_waypoint_info <: Abstract_C_record
    latitude::IGCLatitude
    longitude::IGCLongitude
    description::String
end

struct D_record <: Abstract_IGC_record
    qualifier::GpsQualifier.GpsQualifierEnum
    station_id::String
end

struct E_record <: Abstract_IGC_record
    time::Time
    tlc::String
    extension_string::String
end

struct F_record <: Abstract_IGC_record
    time::Time
    satellites::Vector{String}
end

struct G_record <: Abstract_IGC_record
    value::String
end

abstract type Abstract_H_record <: Abstract_IGC_record end

struct K_record <: Abstract_IGC_record
    time::Time
    value_string::String
    start_index::Int64
end

struct L_record <: Abstract_IGC_record
    source::String
    comment::String

    function L_record(source, comment)
        @assert length(source) == 3
        new(source, comment)
    end
end

# ========================================

struct H_record_DaTE <: Abstract_H_record
    source::Char
    value::Date
end
H_record_DaTE(value; source=DEFAULT_SOURCE) = H_record_DaTE(source, value)
H_record_DaTE(y, m, d; source=DEFAULT_SOURCE) = H_record_DaTE(source, Date(y, m, d))
tlc(::H_record_DaTE) = "DTE"

struct H_record_FiXAccuracy <: Abstract_H_record
    source::Char
    value::Union{Missing, Int64}
end
H_record_FiXAccuracy(value; source=DEFAULT_SOURCE) = H_record_FiXAccuracy(source, value)
tlc(::H_record_FiXAccuracy) = "FXA"

struct H_record_PiLoT <: Abstract_H_record
    source::Char
    value::String
end
H_record_PiLoT(value; source=DEFAULT_SOURCE) = H_record_PiLoT(source, value)
tlc(::H_record_PiLoT) = "PLT"
subtype_long(::H_record_PiLoT) = "PILOTINCHARGE"

struct H_record_Copilot <: Abstract_H_record
    source::Char
    value::String
end
H_record_Copilot(value; source=DEFAULT_SOURCE) = H_record_Copilot(source, value)
tlc(::H_record_Copilot) = "CM2"
subtype_long(::H_record_Copilot) = "CREW2"

struct H_record_GliderType <: Abstract_H_record
    source::Char
    value::String
end
H_record_GliderType(value; source=DEFAULT_SOURCE) = H_record_GliderType(source, value)
tlc(::H_record_GliderType) = "GTY"
subtype_long(::H_record_GliderType) = "GLIDERTYPE"

struct H_record_GliderRegistration <: Abstract_H_record
    source::Char
    value::String
end
H_record_GliderRegistration(value; source=DEFAULT_SOURCE) = H_record_GliderRegistration(source, value)
tlc(::H_record_GliderRegistration) = "GID"
subtype_long(::H_record_GliderRegistration) = "GLIDERID"

struct H_record_GpsDatum <: Abstract_H_record
    source::Char
    value::String
end
H_record_GpsDatum(value; source=DEFAULT_SOURCE) = H_record_GpsDatum(source, value)
tlc(::H_record_GpsDatum) = "DTM"
subtype_long(::H_record_GpsDatum) = "100GPSDATUM"

struct H_record_FirmwareRevision <: Abstract_H_record
    source::Char
    value::String
end
H_record_FirmwareRevision(value; source=DEFAULT_SOURCE) = H_record_FirmwareRevision(source, value)
tlc(::H_record_FirmwareRevision) = "RFW"
subtype_long(::H_record_FirmwareRevision) = "FIRMWAREVERSION"

struct H_record_HardwareRevision <: Abstract_H_record
    source::Char
    value::String
end
H_record_HardwareRevision(value; source=DEFAULT_SOURCE) = H_record_HardwareRevision(source, value)
tlc(::H_record_HardwareRevision) = "RHW"
subtype_long(::H_record_HardwareRevision) = "HARDWAREVERSION"

struct H_record_ManufacturerModel <: Abstract_H_record
    source::Char
    manufacturer::String
    model::String
end
H_record_ManufacturerModel(manufacturer, model; source=DEFAULT_SOURCE) = H_record_ManufacturerModel(source, manufacturer, model)
tlc(::H_record_ManufacturerModel) = "FTY"
subtype_long(::H_record_ManufacturerModel) = "FRTYPE"


struct MaxAlt
    value::Union{Missing, Int64}
    unit::String
end
MaxAlt() = MaxAlt(missing, "")

struct H_record_GpsReceiver <: Abstract_H_record
    source::Char
    manufacturer::String
    model::String
    channels::Union{Missing, Int64}
    max_alt::MaxAlt
end
H_record_GpsReceiver(manufacturer, model, channels, max_alt; source=DEFAULT_SOURCE) = H_record_GpsReceiver(source, manufacturer, model, channels, max_alt)
tlc(::H_record_GpsReceiver) = "GPS"

struct H_record_PressureAltitudeSensor <: Abstract_H_record
    source::Char
    manufacturer::String
    model::String
    max_alt::MaxAlt
end
H_record_PressureAltitudeSensor(manufacturer, model, max_alt; source=DEFAULT_SOURCE) = H_record_PressureAltitudeSensor(source, manufacturer, model, max_alt)
tlc(::H_record_PressureAltitudeSensor) = "PRS"
subtype_long(::H_record_PressureAltitudeSensor) = "PRESSALTSENSOR"

struct H_record_CompetitionId <: Abstract_H_record
    source::Char
    value::String
end
H_record_CompetitionId(value; source=DEFAULT_SOURCE) = H_record_CompetitionId(source, value)
tlc(::H_record_CompetitionId) = "CID"
subtype_long(::H_record_CompetitionId) = "COMPETITIONID"

struct H_record_CompetitionClass <: Abstract_H_record
    source::Char
    value::String
end
H_record_CompetitionClass(value; source=DEFAULT_SOURCE) = H_record_CompetitionClass(source, value)
tlc(::H_record_CompetitionClass) = "CCL"
subtype_long(::H_record_CompetitionClass) = "COMPETITIONCLASS"

struct H_record_TimeZoneOffset <: Abstract_H_record
    source::Char
    value::FixedTimeZone
end
function H_record_TimeZoneOffset(minutes::Int64; source=DEFAULT_SOURCE)
    secs = minutes * 60
    value = FixedTimeZone("UTC" * TimeZones.offset_string(Second(secs), true), Second(secs))
    return H_record_TimeZoneOffset(source, value)
end
tlc(::H_record_TimeZoneOffset) = "TZN"
subtype_long(::H_record_TimeZoneOffset) = "TIMEZONE"
# FixedTimeZone("", 3 * 60 * 60)
# FixedTimeZone("0300")
# ToDo: https://github.com/JuliaTime/TimeZones.jl/issues/233

struct H_record_MeansOfPropulsion <: Abstract_H_record
    source::Char
    value::String
end
H_record_MeansOfPropulsion(value; source=DEFAULT_SOURCE) = H_record_MeansOfPropulsion(source, value)
tlc(::H_record_MeansOfPropulsion) = "MOP"
subtype_long(::H_record_MeansOfPropulsion) = "SENSOR"

struct H_record_Site <: Abstract_H_record
    source::Char
    value::String
end
H_record_Site(value; source=DEFAULT_SOURCE) = H_record_Site(source, value)
tlc(::H_record_Site) = "SIT"
subtype_long(::H_record_Site) = "Site"

struct H_record_UnitsOfMeasure <: Abstract_H_record
    source::Char
    value::Vector{String}
end
H_record_UnitsOfMeasure(value; source=DEFAULT_SOURCE) = H_record_UnitsOfMeasure(source, value)
tlc(::H_record_UnitsOfMeasure) = "UNT"
subtype_long(::H_record_UnitsOfMeasure) = "Units"

# ========================================

mutable struct Header
    fix_accuracy::Union{Missing, H_record_FiXAccuracy}

    # required
    date::Union{Missing, H_record_DaTE}
    pilot_in_charge::Union{Missing, H_record_PiLoT}
    crew2::Union{Missing, H_record_Copilot}
    glider_type::Union{Missing, H_record_GliderType}
    glider_id::Union{Missing, H_record_GliderRegistration}
    gps_datum::Union{Missing, H_record_GpsDatum}
    firmware_version::Union{Missing, H_record_FirmwareRevision}
    hardware_version::Union{Missing, H_record_HardwareRevision}
    flight_recorder_type::Union{Missing, H_record_ManufacturerModel}
    gps_receiver::Union{Missing, H_record_GpsReceiver}
    pressure_altitude_sensor::Union{Missing, H_record_PressureAltitudeSensor}

    # additional
    competition_id::Union{Missing, H_record_CompetitionId}
    competition_class::Union{Missing, H_record_CompetitionClass}

    function Header(fix_accuracy=missing, date=missing, pilot_in_charge=missing, crew2=missing, glider_type=missing,
        glider_id=missing, gps_datum=missing, firmware_version=missing, hardware_version=missing,
        flight_recorder_type=missing, gps_receiver=missing, pressure_altitude_sensor=missing, competition_id=missing,
        competition_class=missing)
        new(fix_accuracy, date, pilot_in_charge, crew2, glider_type,
            glider_id, gps_datum, firmware_version, hardware_version,
            flight_recorder_type, gps_receiver, pressure_altitude_sensor, competition_id,
            competition_class)
    end
end

mutable struct Task
    info::C_record_task_info
    waypoints::Vector{C_record_waypoint_info}
    Task(info) = new(info, C_record_waypoint_info[])
    Task() = new()
end

const D_HEADER_RECORD_FIELD = Dict(
    H_record_FiXAccuracy => :fix_accuracy,
    H_record_DaTE => :date,
    H_record_PiLoT => :pilot_in_charge,
    H_record_Copilot => :crew2,
    H_record_GliderType => :glider_type,
    H_record_GliderRegistration => :glider_id,
    H_record_GpsDatum => :gps_datum,
    H_record_FirmwareRevision => :firmware_version,
    H_record_HardwareRevision => :hardware_version,
    H_record_ManufacturerModel => :flight_recorder_type,
    H_record_GpsReceiver => :gps_receiver,
    H_record_PressureAltitudeSensor => :pressure_altitude_sensor,
    H_record_CompetitionId => :competition_id,
    H_record_CompetitionClass => :competition_class    
)

# ========================================

# flc: first letter character

flc(rec::A_record) = 'A'
flc(rec::B_record) = 'B'
flc(rec::C_record_task_info) = 'C'
flc(rec::C_record_waypoint_info) = 'C'
flc(rec::D_record) = 'D'
flc(rec::E_record) = 'E'
flc(rec::F_record) = 'F'
flc(rec::G_record) = 'G'
flc(rec::T) where {T <: Abstract_H_record} = 'H'
flc(rec::I_record) = 'I'
flc(rec::J_record) = 'J'
flc(rec::K_record) = 'K'
flc(rec::L_record) = 'L'

# ========================================

const D_RECORD_CHAR = Dict(
    'A' => A_record,
    'B' => B_record,
    'C' => Abstract_C_record,
    'D' => D_record,
    'E' => E_record,
    'F' => F_record,
    'G' => G_record,
    'H' => Abstract_H_record,
    'I' => I_record,
    'J' => J_record,
    'K' => K_record,
    'L' => L_record
)

const D_RECORD_FIELD = Dict(
    A_record => :logger_id,
    B_record => :fix_records,
    Abstract_C_record => :task,
    C_record_task_info => :task,
    C_record_waypoint_info => :task,
    D_record => :dgps_records,
    E_record => :event_records,
    F_record => :satellite_records,
    G_record => :security_records,
    Header => :header,
    I_record => :fix_record_extensions,
    J_record => :k_record_extensions,
    K_record => :k_records,
    L_record => :comment_records
)

# ========================================

mutable struct IGCDocument
    logger_id::A_record
    fix_records::Vector{B_record}
    task::Task
    # tasks::Vector{Task}
    dgps_records::Vector{D_record}
    event_records::Vector{E_record}
    satellite_records::Vector{F_record}
    security_records::Vector{G_record}
    header::Header
    fix_record_extensions::I_record
    k_record_extensions::J_record
    k_records::Vector{K_record}
    comment_records::Vector{L_record}
    errors::Vector{IGCParseException}
    eol::String
    stream::IO
    parsing_mode::ParsingMode.ParsingModeEnum
    #dt_first::ZonedDateTime
    #dt_last::ZonedDateTime
end
IGCDocument(; stream = devnull, eol = EOL_DEFAULT, parsing_mode=ParsingMode.DEFAULT) = IGCDocument(
    A_record(),
    B_record[],
    Task(),
    #Task[],
    D_record[],
    E_record[],
    F_record[],
    G_record[],
    Header(),
    I_record(),
    J_record(),
    K_record[],
    L_record[],
    IGCParseException[],
    eol,
    stream,
    parsing_mode,
    #ZonedDateTime(0, TZ),
    #ZonedDateTime(0, TZ)
)

have_task_declared(igcdoc::IGCDocument) = igcdoc.task.info.declaration.date != EmptyDate()
