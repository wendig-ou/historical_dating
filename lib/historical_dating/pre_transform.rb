class HistoricalDating::PreTransform < Parslet::Transform
  rule(from: subtree(:from), to: subtree(:to)) do
    bc = to[:acbc] && (to[:acbc].match(/(vor|v.) (Chr.|Christus)/) || to[:acbc].match(/B(C|c)/))

    if bc
      from[:acbc] = to[:acbc]
    end

    # To detect the first range of e.g.: 2. - 3. Jhd, :acbc key is needed.
    # TODO: Find a better solution.
    if from.is_a?(Hash) && to.is_a?(Hash) && !from.key?(:acbc) && to.key?(:acbc) && !to[:acbc]
      from[:acbc] = nil
    end

    if !bc && to[:num].to_s.size == 2 && to[:cs].nil?
      # for e.g.: 1890/91 but not for e.g.: 150 - 60 v. Chr.
      to[:num] = (from[:num].to_i / 100).to_s + to[:num]
    end

    {from: from, to: to}
  end

  # detect century by :cd and add :cs
  rule(num: simple(:num), approx: simple(:approx), acbc: simple(:acbc), cd: simple(:cd)) do |data|
    if data[:cd]
      data.delete :cd
      data.merge(
        cs: 'Jahrhundert'
      )
    else
      data.delete :cd
      data
    end
  end

  # detect century by :cd and add :cs
  rule(num: simple(:num), approx: simple(:approx), cd: simple(:cd)) do |data|
    if data[:cd]
      data.delete :cd
      data.merge(
        cs: 'Jahrhundert'
      )
    else
      data.delete :cd
      data
    end
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

  # remove :prefix
  rule(prefix: simple(:prefix)) do |data|
    data.delete :prefix
    data
  end
end
