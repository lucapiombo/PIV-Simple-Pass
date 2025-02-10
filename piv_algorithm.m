function [U, V] = piv_algorithm(i, j, x_grid, y_grid, magn, ...
                                window_size, imag1_filtered, imag2_filtered, ...
                                Deltat)

        % Estrai la finestra dalla prima immagine
        x_start = x_grid(i, j);
        y_start = y_grid(i, j);
        window1 = imag1_filtered(y_start:(y_start+window_size-1), x_start:(x_start+window_size-1));

        % Estrai la finestra corrispondente dalla seconda immagine
        window2 = imag2_filtered(y_start:(y_start+window_size-1), x_start:(x_start+window_size-1));
        
        % Calcola le trasformate di Fourier delle finestre
        F1 = fft2(window1);
        F2 = fft2(window2);

        % Calcola la correlazione tramite la moltiplicazione delle trasformate
        C = ifft2(F1 .* conj(F2));
        
        % Shift per centrare il picco
        % Trova il massimo della correlazione
        [maxval, max_idx] = max(C(:));
        [dy_sub, dx_sub] = ind2sub(size(C), max_idx);

        if isnan(maxval)
            dx_sub = 0;
            dy_sub = 0;
        end
         
        if dx_sub>window_size/2  % aggiunto
            dx_sub = dx_sub - window_size;
        end
         
        if dy_sub>window_size/2  % aggiunto
            dy_sub = dy_sub - window_size;
        end

        % Interpolazione parabolica (Estrai i valori attorno al picco)
        if dx_sub > 1 && dx_sub < size(C, 2) && dy_sub > 1 && dy_sub < size(C, 1)
 
            % Valori della matrice attorno al massimo
            neighborhood = C(dy_sub-1:dy_sub+1, dx_sub-1:dx_sub+1);
            [X, Y] = meshgrid(-1:1, -1:1);
            A = [X(:).^2, Y(:).^2, X(:).*Y(:), X(:), Y(:), ones(9, 1)];
            b = neighborhood(:);
            coeff = A\b; % Risolvi i coefficienti
            dx_sub1 = -coeff(4) / (2 * coeff(1));
            dy_sub1 = -coeff(5) / (2 * coeff(2));
            dx_sub = dx_sub1 + dx_sub - 2; % Aggiusta rispetto al sistema globale
            dy_sub = dy_sub1 + dy_sub - 2;  

            % if dx_sub > size(C, 2) || dy_sub > size(C, 1)
            %   error
            % end
        end
   
        U = (dx_sub .* (1/magn).*1e-3) ./ Deltat;
        V = (dy_sub .* (1/magn).*1e-3) ./ Deltat;

end
