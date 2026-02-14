use std::fs;
use std::io::{self, BufRead};

#[derive(Debug)]
pub struct RamStats {
    pub total_ram_gb: f64,
    pub used_ram_gb: f64,
    pub free_ram_gb: f64,
    pub occupancy_percent: f64,
}

impl RamStats {
    /// Parse /proc/meminfo and calculate RAM statistics
    pub fn from_proc_meminfo() -> Result<Self, io::Error> {
        let file = fs::File::open("/proc/meminfo")?;
        let reader = io::BufReader::new(file);

        let mut total_kb: u64 = 0;
        let mut available_kb: u64 = 0;

        for line in reader.lines() {
            let line = line?;
            let parts: Vec<&str> = line.split(':').collect();

            if parts.len() < 2 {
                continue;
            }

            let key = parts[0].trim();
            let value_str = parts[1].trim();
            let value_kb: u64 = value_str
                .split_whitespace()
                .next()
                .and_then(|s| s.parse().ok())
                .unwrap_or(0);

            match key {
                "MemTotal" => total_kb = value_kb,
                "MemAvailable" | "MemFree" => available_kb = value_kb,
                _ => continue,
            }
        }

        if total_kb == 0 {
            return Err(io::Error::new(
                io::ErrorKind::NotFound,
                "Could not find MemTotal in /proc/meminfo",
            ));
        }

        let total_gb = total_kb as f64 / 1024.0 / 1024.0;
        let used_gb = total_gb - (available_kb as f64 / 1024.0 / 1024.0);
        let occupancy_percent = (used_gb / total_gb) * 100.0;

        Ok(RamStats {
            total_ram_gb: total_gb,
            used_ram_gb: used_gb,
            free_ram_gb: available_kb as f64 / 1024.0 / 1024.0,
            occupancy_percent,
        })
    }

    /// Format the stats as a human-readable string
    pub fn to_string(&self) -> String {
        format!(
            "RAM Statistics:\n  Total RAM: {:.2} GB\n  Used RAM: {:.2} GB ({:.1}%)\n  Free RAM: {:.2} GB",
            self.total_ram_gb, self.used_ram_gb, self.occupancy_percent, self.free_ram_gb
        )
    }
}

fn main() {
    match RamStats::from_proc_meminfo() {
        Ok(stats) => {
            println!("{}", stats.to_string());
        }
        Err(e) => {
            eprintln!("Error reading RAM stats: {}", e);
            std::process::exit(1);
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_ram_stats_parsing() {
        // Mock the /proc/meminfo reading for testing
        let mock_meminfo = "MemTotal:       8388608 kB\nMemAvailable:  2097152 kB\nMemFree:      2097152 kB\nBuffers:       524288 kB\nCached:      1048576 kB";
        let original_read_to_string = std::fs::read_to_string;
        std::fs::read_to_string = |_| Ok(mock_meminfo.to_string());

        let stats = RamStats::from_proc_meminfo().unwrap();

        // Restore original function
        std::fs::read_to_string = original_read_to_string;

        // Verify calculations
        assert_eq!(stats.total_ram_gb, 8.0); // 8388608 KB = 8 GB
        assert_eq!(stats.free_ram_gb, 2.0);  // 2097152 KB = 2 GB
        assert_eq!(stats.used_ram_gb, 6.0);  // 8 - 2 = 6 GB
        assert!((stats.occupancy_percent - 75.0).abs() < 0.01); // 6/8 = 75%
    }
}
