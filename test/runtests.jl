using IGC
using Test
# import IGC: IGCDocument, Abstract_IGC_record
import IGC: IGCTimeFormat, IGCDateFormat, EmptyTime, EmptyDate
import IGC: IGCLatitude, IGCLongitude, FixValidity, IGCPressureAltitude, IGCGpsAltitude, TZ
import IGC: flc, A_record, B_record, D_record, GpsQualifier
import IGC: Abstract_C_record, C_record_task_info, C_record_waypoint_info
import IGC: E_record, F_record, G_record, IGCExtension, I_record, J_record
import IGC: Abstract_H_record, update, DEFAULT_SOURCE
import IGC: H_record_FiXAccuracy, H_record_DaTE, H_record_PiLoT, H_record_Copilot, H_record_GliderType, H_record_GliderRegistration
import IGC: H_record_GpsDatum, H_record_FirmwareRevision, H_record_HardwareRevision, H_record_ManufacturerModel
import IGC: H_record_GpsReceiver, MaxAlt, H_record_PressureAltitudeSensor
import IGC: H_record_CompetitionId, H_record_CompetitionClass
import IGC: H_record_TimeZoneOffset, H_record_MeansOfPropulsion, H_record_Site, H_record_UnitsOfMeasure
import IGC: K_record, L_record
import IGC: update!, Header, EOL_DEFAULT

using Dates
using TimeZones

include("test_reader.jl")
include("test_writer.jl")
include("test_filename.jl")
