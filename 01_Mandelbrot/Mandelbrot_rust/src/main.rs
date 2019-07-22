use std::char;

// TODO: https://docs.rs/ndarray and https://docs.rs/ndarray-parallel

fn main() {
    let width = 100;
    let height = 25;
    let max_val = 256;
    let repeat = 1000;
    let x_center = -0.5;
    let y_center = 0.0;
    let x_range = 3.0;
    let y_range = 2.0;

    let mut output = vec![0; height * width];
    // Warmup
    compute_mandelbrot(
        &mut output,
        max_val,
        width,
        width,
        height,
        x_center,
        y_center,
        x_range,
        y_range,
    );
    let start = std::time::Instant::now();
    for _ in 0..repeat {
        compute_mandelbrot(
            &mut output,
            max_val,
            width,
            width,
            height,
            x_center,
            y_center,
            x_range,
            y_range,
        );
    }
    let end = std::time::Instant::now();
    let mean_runtime = (end.duration_since(start).as_nanos() as f32) / (1e6 * (repeat as f32));
    println!("Rust: {} ms", mean_runtime);
    print_result(&output, width, width, height);
}

fn compute_single(x_val: f32, y_val: f32, max_val: u32) -> u32 {
    let mut z_re = x_val;
    let mut z_im = y_val;
    let mut z_re2 = x_val * x_val;
    let mut z_im2 = y_val * y_val;
    let mut z_re_im; // Don't need it right now
    let mut val = 0;

    while val < max_val && z_im2 + z_re2 < 4.0 {
        z_re_im = z_re * z_im;
        z_re = z_re2 - z_im2 + x_val;
        z_im = z_re_im + z_re_im + y_val;
        z_re2 = z_re * z_re;
        z_im2 = z_im * z_im;
        val += 1;
    }

    return val;
}

fn compute_mandelbrot(
    result: &mut Vec<u32>,
    max_val: u32,
    stride: usize,
    width: usize,
    height: usize,
    x_center: f32,
    y_center: f32,
    x_range: f32,
    y_range: f32,
) {
    let x_min = x_center - x_range / 2.0;
    let x_max = x_center + x_range / 2.0;
    let y_min = y_center - y_range / 2.0;
    let y_max = y_center + y_range / 2.0;

    let x_step = (x_max - x_min) / ((width - 1) as f32);
    let y_step = (y_max - y_min) / ((height - 1) as f32);

    for y in 0..height {
        let y_val = (y as f32) * y_step + y_min;
        for x in 0..width {
            let x_val = (x as f32) * x_step + x_min;
            result[y * stride + x] = compute_single(x_val, y_val, max_val);
        }
    }
}


fn print_result(result: &Vec<u32>, stride: usize, width: usize, height: usize) {
    for y in 0..height {
        for x in 0..width {
            print!(
                "{}",
                char::from_u32(32 + result[y * stride + x] & 63)
                    .unwrap()
                    .to_string()
            );
        }
        println!()
    }
}
