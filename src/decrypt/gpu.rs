use super::opencl;
use crate::hash::Hash;
use crate::options;
use crate::summary;

use crate::options::SharedAccessor;

fn compute_results<'a, H: Hash>(
    environment: &opencl::Environment<'a, H>,
    input: &[H],
    out_buffer: &ocl::Buffer<opencl::Output>,
    options: &options::Decrypt<H>,
) -> Vec<summary::Decrypted> {
    let mut output = vec![opencl::Output::default(); out_buffer.len()];
    out_buffer.read(&mut output).enq().unwrap_or_else(|err| {
        panic!("OpenCL: Failed to read output buffer: {}", err);
    });

    let mut results = Vec::with_capacity(out_buffer.len());

    for (i, plain) in output.iter().enumerate() {
        if plain.is_valid() {
            results.push(summary::Decrypted::new(
                input[i].to_string(),
                format!("{}{}", &options.prefix(), plain.printable(&environment)),
            ));
        }
    }

    // The kernel will output zeros if nothing is found
    // We should hash this in the CPU to make sure it doesn't match anything
    if results.len() < input.len() {
        let salted_prefix = format!("{}{}", &options.salt(), &options.prefix());

        for i in 0..environment.cpu_iterations() {
            use eytzinger::SliceExt;

            let zeros = opencl::Output::new(0, i).printable(&environment);
            let hash = H::digest(&salted_prefix, &zeros);

            if input.eytzinger_search(&hash).is_some() {
                let result = format!("{}{}", &options.prefix(), &zeros);
                results.push(summary::Decrypted::new(hash.to_string(), result));
            }

            if results.len() == input.len() {
                break;
            }
        }
    }

    results
}

pub fn execute<H: Hash>(options: &options::Decrypt<H>) -> summary::Decrypt {
    let time = std::time::Instant::now();

    if (options.input().len() as u64) >= (i32::max_value() as u64) {
        panic!("Input count too large. GPU kernel defines are fixed at i32 (2,147,483,647)");
    }

    let input = options.input_as_eytzinger();

    let environment = opencl::setup_for(options);
    let program = environment.make_program();

    let in_buffer = ocl::Buffer::builder()
        .flags(ocl::MemFlags::READ_ONLY)
        .len(options.input().len())
        .queue(environment.queue().clone())
        .copy_host_slice(&input)
        .build()
        .unwrap_or_else(|err| {
            panic!("OpenCL: Failed to create input buffer: {}", err);
        });

    let out_buffer = ocl::Buffer::builder()
        .flags(ocl::MemFlags::WRITE_ONLY)
        .len(options.input().len())
        .queue(environment.queue().clone())
        .build()
        .unwrap_or_else(|err| {
            panic!("OpenCL: Failed to create output buffer: {}", err);
        });

    options.printer().progress(0);
    for i in 0..environment.cpu_iterations() {
        let kernel = ocl::Kernel::builder()
            .program(&program)
            .name("crack")
            .queue(environment.queue().clone())
            .global_work_size(environment.range())
            .arg(&in_buffer)
            .arg(&out_buffer)
            .arg(i)
            .build()
            .unwrap_or_else(|err| {
                panic!("OpenCL: Failed to build kernel: {}", err);
            });

        unsafe {
            kernel.enq().unwrap_or_else(|err| {
                panic!("OpenCL: Failed to enqueue kernel: {}", err);
            });
        }

        // If we enqueue too many, OpenCL will abort
        // Send every 7th iteration
        if i & 0b111 == 0b111 {
            options
                .printer()
                .progress(i * 100 / environment.cpu_iterations());
            environment.queue().finish().unwrap_or_else(|err| {
                panic!(
                    "OpenCL: Failed to wait for queue segment to finish: {}",
                    err
                );
            });
        }
    }

    environment.queue().finish().unwrap_or_else(|err| {
        panic!("OpenCL: Failed to wait for queue to finish: {}", err);
    });
    options.printer().clear_progress();

    let results = compute_results(&environment, &input, &out_buffer, &options);

    if !results.is_empty() {
        if input.len() == 1 {
            println!("{}", results[0].plain);
        } else {
            for result in &results {
                println!("{}:{}", result.hash, result.plain);
            }
        }
    }

    summary::Decrypt {
        total_count: input.len(),
        duration: time.elapsed(),
        hash_count: options.number_space(),
        threads: environment.range(),
        results,
    }
}
