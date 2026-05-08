import Foundation
import IOKit.ps

struct BatterySampler {
    func sample() -> BatterySample? {
        guard let snapshot = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
              let powerSources = IOPSCopyPowerSourcesList(snapshot)?.takeRetainedValue() as? [CFTypeRef] else {
            return nil
        }

        for source in powerSources {
            guard let description = IOPSGetPowerSourceDescription(snapshot, source)?.takeUnretainedValue() as? [String: Any],
                  let currentCapacity = description[kIOPSCurrentCapacityKey] as? NSNumber,
                  let maxCapacity = description[kIOPSMaxCapacityKey] as? NSNumber,
                  maxCapacity.doubleValue > 0 else {
                continue
            }

            let ratio = min(1, max(0, currentCapacity.doubleValue / maxCapacity.doubleValue))
            let isCharging = (description[kIOPSIsChargingKey] as? NSNumber)?.boolValue ?? false

            return BatterySample(chargeRatio: ratio, isCharging: isCharging)
        }

        return nil
    }
}
