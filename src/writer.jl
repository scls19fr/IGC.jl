import Base: string

string(d::IGCDate) = Dates.format(d.val, IGC_DATE_FMT)
string(dt::IGCTime) = Dates.format(dt.val, IGC_TIME_FMT)

#import Base: write
#function write(stream::IO, igcdoc::IGCDocument)
#
#end
