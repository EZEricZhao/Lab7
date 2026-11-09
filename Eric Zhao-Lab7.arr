use context dcic2024
#| Lab 7: Binary Trees (Sensor Network Analysis)
   data SensorNet:
     | hub(bandwidth :: Number, left :: SensorNet, right :: SensorNet)
     | sensor(rate :: Number)
   end
|#

data SensorNet:
  | hub(bandwidth :: Number, left :: SensorNet, right :: SensorNet)
  | sensor(rate :: Number)
end

# Example network
sA = sensor(60)
sB = sensor(120)
sC = sensor(45)

hub1 = hub(150, sA, sB)
core = hub(200, hub1, sC)



# Task 1 - Compute Total Offered Load
fun total-load(n :: SensorNet) -> Number:
  doc: "Returns the sum of all sensor rates in the network"
  cases (SensorNet) n:
    | sensor(rate) => rate
    | hub(bw, l, r) => total-load(l) + total-load(r)
  end
where:
  total-load(sA) is 60
  total-load(hub1) is 180
  total-load(core) is 225
end



# Task 2 - Check Capacity Feasibility
fun fits-capacities(n :: SensorNet) -> Boolean:
  doc: "Returns true if every hub's bandwidth >= total load of its children"
  cases (SensorNet) n:
    | sensor(rate) => true
    | hub(bw, l, r) =>
      block:
        child-load = total-load(l) + total-load(r)
        (bw >= child-load) and fits-capacities(l) and fits-capacities(r)
      end
  end
where:
  # hub1 has bandwidth 150 but children load 60+120 = 180 -> not feasible
  fits-capacities(hub1) is false
  # Replace hub1 with a feasible version (bandwidth 180 for load 60+120)
  feasible-hub1 = hub(180, sA, sB)
  fits-capacities(hub(225, feasible-hub1, sC)) is true
  # A single sensor is trivially feasible
  fits-capacities(sA) is true
  # core: bw 200, children load 180+45 = 225 -> not feasible
  fits-capacities(core) is false
end



# Task 3 - Depth of the Deepest Sensor
fun deepest-depth(n :: SensorNet) -> Number:
  doc: "Returns the depth of the deepest sensor; a single sensor has depth 0"
  cases (SensorNet) n:
    | sensor(rate) => 0
    | hub(bw, l, r) =>
      block:
        left-depth = deepest-depth(l)
        right-depth = deepest-depth(r)
        num-max(left-depth, right-depth) + 1
      end
  end
where:
  deepest-depth(sA) is 0
  deepest-depth(hub1) is 1
  deepest-depth(core) is 2
end



# Task 4 - Apply a Scaling Factor
fun apply-scale(n :: SensorNet, s :: Number) -> SensorNet:
  doc: "Divides every sensor rate by s, rebuilding hubs with same bandwidth"
  cases (SensorNet) n:
    | sensor(rate) => sensor(rate / s)
    | hub(bw, l, r) => hub(bw, apply-scale(l, s), apply-scale(r, s))
  end
where:
  scaled = apply-scale(core, 1.2)
  total-load(scaled) is 187.5
  # Scaling by 2:
  total-load(apply-scale(core, 2)) is 112.5
  # Scaling a single sensor:
  apply-scale(sA, 2) is sensor(30)
end

# Helper: needed-scale (provided)
fun needed-scale(n :: SensorNet) -> Number:
  doc: "Computes the minimal scaling factor so the network fits capacities"
  cases (SensorNet) n:
    | sensor(rate) => 1
    | hub(bw, l, r) =>
      block:
        load = total-load(l) + total-load(r)
        here = load / bw
        num-max(num-max(here, needed-scale(l)), needed-scale(r))
      end
  end
where:
  needed-scale(sA) is 1
  needed-scale(hub1) is 1.2
  needed-scale(core) is 1.2
end



# Task 5 - (Optional) Scale the Network to Fit
fun scale-to-fit(n :: SensorNet) -> SensorNet:
  doc: "Scales network just enough so it is feasible"
  s = needed-scale(n)
  if s <= 1:
    n
  else:
    apply-scale(n, s)
  end
where:
  fitted = scale-to-fit(core)
  fits-capacities(fitted) is true
  total-load(fitted) is 187.5   # 225 / 1.2
  # Already-feasible network stays unchanged
  scale-to-fit(sA) is sensor(60)
end