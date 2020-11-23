class HistoricalDating::PreTransform < Parslet::Transform
  rule(from: subtree(:from), to: subtree(:to)) do
    if to[:acbc] && (to[:acbc].match(/(vor|v.) (Chr.|Christus)/) || to[:acbc].match(/BC/))
      from[:acbc] = to[:acbc]
    end

    if to[:num].to_s.size == 2 && to[:cs].nil?
      # e.g.: 1890/91
      to[:num] = (from[:num].to_i / 100).to_s + to[:num]
    end

    {from: from, to: to}
  end

  # detect century by :cd and add :cs
  rule(num: simple(:num), approx: simple(:approx), acbc: simple(:acbc), cd: simple(:cd)) do |data|
    data.delete :cd
    data.merge(
      cs: 'Jahrhundert'
    )
  end

  # detect century by :cd and add :cs
  rule(num: simple(:num), approx: simple(:approx), cd: simple(:cd)) do |data|
    data.delete :cd
    data.merge(
      cs: 'Jahrhundert'
    )
  end

  # remove :cd if :cs already present (with acbc)
  rule(num: simple(:num), approx: simple(:approx), acbc: simple(:acbc), cd: simple(:cd), cs: simple(:cs)) do |data|
    data.delete :cd
    data
  end

  # remove :cd if :cs already present (no acbc)
  rule(num: simple(:num), approx: simple(:approx), cd: simple(:cd), cs: simple(:cs)) do |data|
    data.delete :cd
    data
  end
end
