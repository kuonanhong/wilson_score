require "wilson_score/version"

module WilsonScore

  # http://en.wikipedia.org/wiki/Binomial_proportion_confidence_interval
  def self.interval(k, n, confidence, correction = false)
    z = pnorm(1 - (1 - confidence) / 2)
    phat = k / n.to_f
    if correction # continuity correction
      a = 1.0 / (2 * (n + z**2))
      b = 2*n*phat + z**2
      c = z * Math.sqrt(z**2 - 1.0/n + 4*n*phat*(1 - phat) + (4*phat - 2)) + 1
      ([0, a * (b - c)].max)..([1, a * (b + c)].min)
    else
      a = 1.0 / (1 + z ** 2 / n)
      b = phat + z ** 2 / (2 * n)
      c = z * Math.sqrt((phat * (1 - phat) + z ** 2 / (4 * n)) / n)
      (a * (b - c))..(a * (b + c))
    end
  end

  def self.rating_interval(avg, n, score_range, confidence, correction = false)
    min = score_range.first
    max = score_range.last
    range = max - min
    interval = interval(n * (avg - min) / range, n, confidence, correction)
    (min + range * interval.first)..(min + range * interval.last)
  end

  protected

  # from the statistics2 gem
  # https://github.com/abscondment/statistics2/blob/master/lib/statistics2/base.rb
  # inverse of normal distribution ([2])
  # Pr( (-\infty, x] ) = qn -> x
  def self.pnorm(qn)
    b = [1.570796288, 0.03706987906, -0.8364353589e-3,
         -0.2250947176e-3, 0.6841218299e-5, 0.5824238515e-5,
         -0.104527497e-5, 0.8360937017e-7, -0.3231081277e-8,
         0.3657763036e-10, 0.6936233982e-12]

    if(qn < 0.0 || 1.0 < qn)
      $stderr.printf("Error : qn <= 0 or qn >= 1  in pnorm()!\n")
      return 0.0;
    end
    qn == 0.5 and return 0.0

    w1 = qn
    qn > 0.5 and w1 = 1.0 - w1
    w3 = -Math.log(4.0 * w1 * (1.0 - w1))
    w1 = b[0]
    1.upto 10 do |i|
      w1 += b[i] * w3**i;
    end
    qn > 0.5 and return Math.sqrt(w1 * w3)
    -Math.sqrt(w1 * w3)
  end

end