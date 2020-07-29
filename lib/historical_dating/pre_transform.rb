class HistoricalDating::PreTransform < Parslet::Transform
  rule(from: subtree(:from), to: subtree(:to)) do
    if to[:acbc] && to[:acbc].match(/(vor|v.) (Chr.|Christus)/)
      from[:acbc] = to[:acbc]
    end
    
    {from: from, to: to}
  end
end
