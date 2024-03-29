use crate::error;
use crate::hash;
use crate::options;
use crate::results;
use crate::Input;

macro_rules! section {
    ($title:literal, $colored:expr) => {
        eprintln!();
        if $colored {
            use colored::Colorize;
            eprintln!("{}", $title.yellow());
        } else {
            eprintln!($title);
        }
        eprintln!("----------");
    };
}

macro_rules! colorize {
    ($title:literal, $colored:expr) => {
        if $colored {
            use colored::Colorize;
            $title.blue()
        } else {
            $title.into()
        }
    };
}

#[derive(Copy, Clone, Debug)]
pub enum Verboseness {
    None = 0,
    Low = 1,
    High = 2,
}

pub fn new(verboseness: Verboseness, colored: bool) -> Printer {
    Printer {
        colored,
        single_input: false,
        verboseness,
    }
}

#[derive(Debug, Copy, Clone)]
pub struct Printer {
    colored: bool,
    single_input: bool,
    verboseness: Verboseness,
}

impl Printer {
    pub fn set_single_input_mode(&mut self) {
        self.single_input = true;
    }

    pub fn options<H: hash::Hash>(self, options: &options::Mode<H>) {
        if self.verboseness as u8 > 1 {
            mode_options(self.colored, options);
            input(self.colored, options);
        }
        if self.verboseness as u8 > 0 {
            section!("Output", self.colored);
        }
    }

    pub fn summary(self, summary: &results::Summary) {
        if self.verboseness as u8 > 0 {
            print_summary(self.colored, summary);
        }
    }

    pub fn files(self) {
        section!("Files", self.colored);
    }

    pub fn read_start(self, file: impl std::convert::AsRef<str>) {
        use std::io::Write;
        if self.colored {
            use colored::Colorize;
            eprint!("{} {}", "Loading".blue(), file.as_ref());
        } else {
            eprint!("Loading {}", file.as_ref());
        }
        let _ignored = std::io::stderr().flush();
    }

    pub fn read_done(self, result: Result<(), error::Error>) {
        if let Err(e) = result {
            if self.colored {
                use colored::Colorize;
                eprintln!(": {} {}", "Error:".bright_red(), e);
            } else {
                eprintln!(": Error: {}", e);
            }
        } else {
            use std::io::Write;
            eprint!("\x1b[1K\r");
            let _ignored = std::io::stderr().flush();
        }
    }

    pub fn write_start(self, file: impl std::convert::AsRef<str>) {
        use std::io::Write;
        if self.colored {
            use colored::Colorize;
            eprint!("{} {}", "Writing".blue(), file.as_ref());
        } else {
            eprint!("Writing {}", file.as_ref());
        }
        let _ignored = std::io::stderr().flush();
    }

    pub fn write_done(self, result: Result<(), error::Error>) {
        use colored::Colorize;
        match result {
            Ok(_) => {
                if self.colored {
                    eprintln!(": {}", "Done".green());
                } else {
                    eprintln!(": Done");
                }
            }
            Err(e) => {
                if self.colored {
                    eprintln!(": {} {}", "Error:".bright_red(), e);
                } else {
                    eprintln!(": Error: {}", e);
                }
            }
        }
    }

    pub fn report(self, input: &str, output: &str) {
        self.clear_progress();
        if self.single_input {
            println!("{}", output);
        } else {
            println!("{}:{}", input, output);
        }
    }

    pub fn progress(self, progress: u8) {
        use std::io::Write;
        if self.colored {
            use colored::Colorize;
            eprint!("\r{} {:02}%", "Progress:".blue(), progress);
        } else {
            eprint!("\rProgress: {:02}%", progress);
        }
        let _ignored = std::io::stderr().flush();
    }

    // Allowed because interface feels better
    #[allow(clippy::unused_self)]
    pub fn clear_progress(self) {
        use std::io::Write;
        eprint!("\x1b[1K\r");
        let _ignored = std::io::stderr().flush();
    }
}

fn mode_options<H: hash::Hash>(colored: bool, options: &options::Mode<H>) {
    section!("Options", colored);
    match options {
        options::Mode::Encrypt(options) => encrypt_options(colored, options),
        options::Mode::Decrypt(options) => decrypt_options(colored, options),
    }

    eprintln!();
}

fn shared_options<T: Input, O: options::SharedAccessor<T>>(
    colored: bool,
    options: &O,
    algorithm: &str,
) {
    eprintln!("{:15}{}", colorize!("Algorithm:", colored), algorithm);
    if !options.salt().is_empty() {
        eprintln!("{:15}{}", colorize!("Salt:", colored), options.salt());
    }
}

fn encrypt_options<H: hash::Hash>(colored: bool, options: &options::Encrypt<H>) {
    shared_options(colored, options, H::name());
}

fn decrypt_options<H: hash::Hash>(colored: bool, options: &options::Decrypt<H>) {
    shared_options(colored, options, H::name());
    if let Some(ref xor) = options.xor() {
        eprintln!("{:15}{}", colorize!("XOR:", colored), base64::encode(xor));
    }
    eprintln!("{:15}{}", colorize!("Device:", colored), options.device());
    if options::Device::Cpu == options.device() {
        eprintln!(
            "{:15}{}",
            colorize!("Threads:", colored),
            if options.threads() == 0 {
                String::from("Auto")
            } else {
                format!("{}", options.threads())
            }
        );
    }
    if !options.prefix().is_empty() {
        eprintln!("{:15}{}", colorize!("Prefix:", colored), options.prefix());
    }
    eprintln!(
        "{:15}{}",
        colorize!("Length:", colored),
        options.length() + options.prefix_length()
    );
    eprintln!(
        "{:15}{}",
        colorize!("Possibilities:", colored),
        number(options.number_space())
    );
}

fn input<H: hash::Hash>(colored: bool, options: &options::Mode<H>) {
    use options::SharedAccessor;
    section!("Input", colored);
    match options {
        options::Mode::Encrypt(mode) => mode.input().iter().for_each(|i| eprintln!("{}", i)),
        options::Mode::Decrypt(mode) => mode.input().iter().for_each(|i| eprintln!("{}", i)),
    }
}

fn print_summary(colored: bool, summary: &results::Summary) {
    section!("Summary", colored);
    eprintln!(
        "{:21}{}",
        colorize!("Threads launched:", colored),
        number(u64::from(summary.threads))
    );
    eprintln!(
        "{:21}{}",
        colorize!("Time elapsed:", colored),
        duration(&summary.duration)
    );
    eprintln!(
        "{:21}{}",
        colorize!("Hashes:", colored),
        number(summary.hash_count)
    );
    if summary.duration.as_micros() == 0 {
        eprintln!("{:21}NaN", colorize!("Hashes per millisec:", colored));
    } else {
        // Allowed because division by micros will not go over u64::max_value()
        #[allow(clippy::cast_possible_truncation)]
        {
            eprintln!(
                "{:21}{}",
                colorize!("Hashes per millisec:", colored),
                number(
                    ((u128::from(summary.hash_count) * 1_000) / summary.duration.as_micros())
                        as u64
                )
            );
        }
    };
    eprintln!(
        "{:21}{}/{} ({}%)",
        colorize!("Values found:", colored),
        summary.results.len(),
        summary.total_count,
        summary.results.len() * 100 / summary.total_count
    );
}

// Allowed because all casts are prepended with check
#[allow(clippy::cast_precision_loss)]
fn number(number: u64) -> String {
    if number < 1000 {
        format!("{}", number)
    } else if number < 1_000_000 {
        let fraction = number as f32 / 1000_f32;
        format!("{} thousand", fraction)
    } else if number < 1_000_000_000 {
        let fraction = (number / 1000) as f32 / 1000_f32;
        format!("{} million", fraction)
    } else if number < 1_000_000_000_000 {
        let fraction = (number / 1_000_000) as f32 / 1000_f32;
        format!("{} billion", fraction)
    } else if number < 1_000_000_000_000_000 {
        let fraction = (number / 1_000_000_000) as f32 / 1000_f32;
        format!("{} trillion", fraction)
    } else {
        format!("{}", number)
    }
}

fn duration(duration: &std::time::Duration) -> String {
    let millis = duration.as_millis();

    // Allowed because modulo 60000 is never grater than u16::MAX (65,536)
    #[allow(clippy::cast_possible_truncation)]
    let seconds = {
        let seconds = f32::from((millis % 60_000) as u16);
        seconds / 1000_f32
    };

    let minutes = millis / 60_000;
    if minutes > 0 {
        format!("{}{:.2}s ({}ms)", minutes, seconds, millis)
    } else {
        format!("{:.2}s ({}ms)", seconds, millis)
    }
}
