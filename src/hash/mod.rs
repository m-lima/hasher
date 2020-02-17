macro_rules! convert {
    ($($algorithm:ty => $hash:ty as $name:ident),+) => {
        $(pub struct $name;

        impl Converter<$algorithm> for $name {
            type Output = $hash;
            fn digest(salted_prefix: &str, number: &str) -> Self::Output {
                use digest::Digest;
                let mut digest = <$algorithm>::new();
                digest.input(salted_prefix.as_bytes());
                digest.input(number.as_bytes());
                let result = digest.result();
                <$hash>::from_array(result)
            }

            fn from_string(string: &str) -> Self::Output {
                <$hash>::from(string)
            }
        })*
    };
}
//
//            #[test]
//            fn compute() {
//                //dd130a849d7b29e5541b05d2f7f86a4acd4f1ec598c1c9438783f56bc4f0ff80
//                let hash = Sha256::digest(&String::from("123"), &String::from("abc"));
//
//                use sha2::Digest;
//                let mut expected_hash = sha2::Sha256::new();
//                expected_hash.input("123".as_bytes());
//                expected_hash.input("abc".as_bytes());
//
//                assert_eq!(
//                    format!("{:x}", hash),
//                    format!("{:x}", expected_hash.result())
//                );
//            }
//        )*

macro_rules! byte_size_of {
    ($size:literal) => {
        $size / 8
    };
}

macro_rules! create_tests {
    ($name:ident[$size:literal]) => {
        #[cfg(test)]
        mod test {
            #[test]
            fn shift() {
                let mut hash = super::Hash::default();
                for i in 0..byte_size_of!($size) {
                    hash.0[i] = (i % 8) as u8;
                }
                hash <<= 2;

                let mut expected = super::Hash::default();
                for i in 0..byte_size_of!($size) {
                    expected.0[i] = (i % 8) as u8 * 4;
                }

                assert_eq!(hash, expected);
            }

            #[test]
            fn shift_overflow() {
                let mut hash = super::Hash::default();
                for i in 0..byte_size_of!($size) {
                    hash.0[i] = 0b1000_0001;
                }
                hash <<= 1;

                let mut expected = super::Hash::default();
                for i in 1..byte_size_of!($size) {
                    expected.0[i] = 0b0000_0011;
                }
                expected.0[0] = 0b0000_0010;

                assert_eq!(hash, expected);
            }

            #[test]
            fn cmp() {
                let mut hash_01 = super::Hash::default();
                hash_01.0[1] = 1;
                let mut hash_02 = super::Hash::default();
                hash_02.0[1] = 2;
                let mut hash_10 = super::Hash::default();
                hash_10.0[0] = 1;
                let mut hash_20 = super::Hash::default();
                hash_20.0[0] = 2;

                assert_eq!(hash_01.cmp(&hash_01), std::cmp::Ordering::Equal);
                assert_eq!(hash_01.cmp(&hash_02), std::cmp::Ordering::Less);
                assert_eq!(hash_01.cmp(&hash_20), std::cmp::Ordering::Greater);
                assert_eq!(hash_01.cmp(&hash_10), std::cmp::Ordering::Greater);
                assert_eq!(hash_10.cmp(&hash_20), std::cmp::Ordering::Less);
            }

            #[test]
            fn string_round_trip() {
                use rand::Rng;
                let mut random = rand::thread_rng();
                let mut string = String::new();

                for _ in 0..byte_size_of!($size) {
                    let value: u8 = random.gen();
                    string = format!("{}{:02x}", string, value);
                }

                let hash = super::Hash::from(string.as_str());
                assert_eq!(format!("{:x}", hash), string);
            }

            //            #[test]
            //            fn parse_string() {
            //                let mut random = rand::thread_rng();
            //
            //                let value: $base = random.gen();
            //                let input = String::from(
            //                    "dd130a849d7b29e5541b05d2f7f86a4acd4f1ec598c1c9438783f56bc4f0ff80",
            //                );
            //                let parsed = Sha256::from_string(&input);
            //
            //                let expected = super::Hash {
            //                    hi: 0x80fff0c46bf5838743c9c198c51e4fcd,
            //                    lo: 0x4a6af8f7d2051b54e5297b9d840a13dd,
            //                };
            //
            //                assert_eq!(parsed, expected);
            //            }
            //
            //            #[test]
            //            fn to_string() {
            //                let hash = super::Hash {
            //                    hi: 0x80fff0c46bf5838743c9c198c51e4fcd,
            //                    lo: 0x4a6af8f7d2051b54e5297b9d840a13dd,
            //                };
            //
            //                assert_eq!(
            //                    format!("{:x}", hash),
            //                    "dd130a849d7b29e5541b05d2f7f86a4acd4f1ec598c1c9438783f56bc4f0ff80"
            //                );
            //            }
        }
    };
}

macro_rules! create_hash {
    ($name:ident[$size:literal]) => {
        mod $name {
            #[derive(PartialEq, Eq, Debug, Hash, Copy, Clone)]
            pub struct Hash([u8; byte_size_of!($size)]);

            unsafe impl ocl::OclPrm for Hash {}

            // Allowed because clippy cannot interpret this macro
            #[allow(clippy::derive_hash_xor_eq)]
            impl $crate::hash::Hash for Hash {
                fn from_array<N: digest::generic_array::ArrayLength<u8>>(
                    bytes: digest::generic_array::GenericArray<u8, N>,
                ) -> Self {
                    let mut data = unsafe {
                        std::mem::MaybeUninit::<[u8; byte_size_of!($size)]>::uninit().assume_init()
                    };
                    data.copy_from_slice(&bytes);
                    Self(data)
                }
            }

            impl Default for Hash {
                fn default() -> Self {
                    Self([0; byte_size_of!($size)])
                }
            }

            impl std::cmp::Ord for Hash {
                fn cmp(&self, other: &Self) -> std::cmp::Ordering {
                    for i in (0..byte_size_of!($size)).rev() {
                        match self.0[i].cmp(&other.0[i]) {
                            std::cmp::Ordering::Equal => (),
                            o => return o,
                        }
                    }
                    std::cmp::Ordering::Equal
                }
            }

            impl std::cmp::PartialOrd for Hash {
                fn partial_cmp(&self, other: &Self) -> Option<std::cmp::Ordering> {
                    for i in (0..byte_size_of!($size)).rev() {
                        match self.0[i].cmp(&other.0[i]) {
                            std::cmp::Ordering::Equal => (),
                            o => return Some(o),
                        }
                    }
                    Some(std::cmp::Ordering::Equal)
                }
            }

            // Allowed because clippy cannot interpret this macro
            #[allow(clippy::suspicious_op_assign_impl)]
            impl std::ops::ShlAssign<u8> for Hash {
                fn shl_assign(&mut self, rhs: u8) {
                    for i in (1..byte_size_of!($size)).rev() {
                        self.0[i] <<= rhs;
                        self.0[i] |= self.0[i - 1] >> (8 - rhs);
                    }
                    self.0[0] <<= rhs;
                }
            }

            impl std::ops::BitOrAssign<u8> for Hash {
                fn bitor_assign(&mut self, rhs: u8) {
                    self.0[byte_size_of!($size) - 1] |= rhs;
                }
            }

            impl std::fmt::LowerHex for Hash {
                fn fmt(&self, fmt: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
                    for b in self.0.iter().rev() {
                        write!(fmt, "{:02x}", &b)?;
                    }
                    Ok(())
                }
            }

            impl std::fmt::Binary for Hash {
                fn fmt(&self, fmt: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
                    for b in self.0.iter().rev() {
                        write!(fmt, "{:08b}", &b)?;
                    }
                    Ok(())
                }
            }

            impl std::fmt::Display for Hash {
                fn fmt(&self, fmt: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
                    std::fmt::LowerHex::fmt(&self, fmt)
                }
            }

            impl std::convert::From<&str> for Hash {
                fn from(string: &str) -> Self {
                    if string.len() != $size >> 2 {
                        eprintln!("String does not fit into hash: {}", &string);
                        std::process::exit(-1);
                    }

                    let mut hash = Self::default();
                    for (i, c) in string.chars().rev().enumerate() {
                        let int = match c as u8 {
                            c if c >= 0x30 && c < 0x3a => c - 0x30, // decimal
                            c if c >= 0x41 && c < 0x47 => c - 0x41 + 0xa, // uppercase
                            c if c >= 0x61 && c < 0x67 => c - 0x61 + 0xa, // lowercase
                            c => {
                                eprintln!("Failed to build hash: invalid character {}", c as char);
                                std::process::exit(-1);
                            }
                        };
                        if i & 1 == 0 {
                            hash.0[i / 2] |= int
                        } else {
                            hash.0[i / 2] |= int << 4;
                        }
                    }
                    hash
                }
            }

            create_tests!($name[$size]);
        }
    };
}

create_hash!(h128[128]);
create_hash!(h256[256]);

pub trait Hash:
    ocl::OclPrm + std::fmt::LowerHex + std::fmt::Binary + ToString + PartialEq + Eq + PartialOrd + Ord
{
    fn from_array<N: digest::generic_array::ArrayLength<u8>>(
        bytes: digest::generic_array::GenericArray<u8, N>,
    ) -> Self;
}

pub trait Converter<D: digest::Digest> {
    type Output: Hash + 'static;
    fn digest(salted_prefix: &str, number: &str) -> Self::Output;
    fn from_string(string: &str) -> Self::Output;
}

convert!(md5::Md5 => h128::Hash as Md5, sha2::Sha256 => h256::Hash as Sha256);
