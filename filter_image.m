function [img_filtered] = filter_image(file, values)

    imag = readB16(file);

    % normalizzare tra 0 e 1 per applicare histeq
    imag_normalized = mat2gray(imag); 
    % 
    % %Applica maschera
    % imag_normalized(mask) = NaN;

    %Aggiusta contrasto
    imag_cont = imadjust(imag_normalized,values,[0 1]);
    
    %filtri
    imag_filtered_gauss = imgaussfilt(imag_cont);
    h = fspecial('average', [3 3]);
    img_filtered = imfilter(imag_filtered_gauss, h); % Crea un filtro di media di dimensione h

end