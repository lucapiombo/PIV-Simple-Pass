clear, clc, close
suffix = "12";

for k = 1: 50

    %Load images
    if k < 10
        file1A = strcat("Gruppo4\"+suffix+"ms\Cam1\Cam1_000", num2str(k, '%d'), "A.b16");
        file1B = strcat("Gruppo4\"+suffix+"ms\Cam1\Cam1_000", num2str(k, '%d'), "B.b16");
    else 
        file1A = strcat("Gruppo4\"+suffix+"ms\Cam1\Cam1_00", num2str(k, '%d'), "A.b16");
        file1B = strcat("Gruppo4\"+suffix+"ms\Cam1\Cam1_00", num2str(k, '%d'), "B.b16"); 
    end
    imag1A_filtered = filter_image(file1A, [0.001 0.05]);
    imag1B_filtered = filter_image(file1B, [0.023 0.074]);

    if k<10
        file2A = strcat("Gruppo4\"+suffix+"ms\Cam2\Cam2_000", num2str(k, '%d'), "A.b16");
        file2B = strcat("Gruppo4\"+suffix+"ms\Cam2\Cam2_000", num2str(k, '%d'), "B.b16");
    else 
        file2A = strcat("Gruppo4\"+suffix+"ms\Cam2\Cam2_00", num2str(k, '%d'), "A.b16");
        file2B = strcat("Gruppo4\"+suffix+"ms\Cam2\Cam2_00", num2str(k, '%d'), "B.b16"); 
    end
    imag2A_filtered = filter_image(file2A, [0.01 0.45]);
    imag2B_filtered = filter_image(file2B, [0.27 0.69]);
    
    imagA_filtered = [imag2A_filtered, imag1A_filtered];
    nameA = strcat("Gruppo4\Big_images\"+suffix+"ms\Cam12_000", num2str(k, '%d'), "A.jpg");
    imwrite(imagA_filtered,nameA)

    imagB_filtered = [imag2B_filtered, imag1B_filtered];
    nameB = strcat("Gruppo4\Big_images\"+suffix+"ms\Cam12_000", num2str(k, '%d'), "B.jpg");
    imwrite(imagB_filtered,nameB)
end