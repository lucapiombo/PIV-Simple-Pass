clear
close all
clc

suffix = "9";

tic
%% Pre-processing per calibrazione

% Carica immagini readB16
imag1 = readB16("test\Calib\Cam1\Cam1_0001.b16");
imag2 = readB16("test\Calib\Cam2\Cam2_0001.b16");

% Conversione in double e aumento contrasto
imag1_normalized = mat2gray(imag1); % essendo di tipo double vado a normalizzare tra 0 e 1 per applicare histeq
imag1_cont = imadjust(imag1_normalized);
imag2_normalized = mat2gray(imag2);
imag2_cont = imadjust(imag2_normalized);

% Filtro per rimuovere rumore e rilevamento cerchi con centro e raggio
imag2_filtered = medfilt2(imag2_cont);

% Trova i cerchi
[centers, radii] = imfindcircles(imag2_filtered, [20 500], 'ObjectPolarity', 'dark', 'Sensitivity', 0.9);

CALIBRATION = 0;
if CALIBRATION
    figure
    hold on
    imshow(imag2_filtered)
    viscircles(centers(5,:), radii(5), 'EdgeColor', 'b');
    viscircles(centers(12,:), radii(12), 'EdgeColor', 'r');
    axis on % Mostra gli assi (di default sono disattivati con imshow)
    xlabel('Asse X (pixel)')
    ylabel('Asse Y (pixel)')
    title('Immagine con assi attivi')
    hold off
    saveas(gca, strcat('post/Gruppo4/calibrazione.svg'),'svg')
end

centro1 = centers(5,:);
centro2 = centers(12,:);
raggio1 = radii(5);
raggio2 = radii(12);

%% Calibrazione spaziale
dist_real = 17.57; % in mm
dist_pix = sqrt((centers(5,1) - centers(12,1))^2 + (centers(5,2) - centers(12,2))^2);

magn = dist_pix/dist_real; % pixel/mm
fprintf('Magnification Factor: %f pxl/mm \n', magn)

%% Calibrazione temporale
vel_1 = 9; %m/s
vel_2 = 12; %m/s
spostamento_medio_pixel = 1/4 *32; %regola un quarto della finestra di campionamento (sottodominio 32x32)
spostamento_medio_reale = spostamento_medio_pixel/magn;
Deltat = spostamento_medio_reale/vel_1*1e-3;

%% Setup dominio di calcolo
window_size = 32; %sottodiminio di calcolo 32x32 pixel
overlap = 16; % Sovrapposizione tra le finestre 50%

% Inizializzazione variabili
allU = [];
allV = [];
dV_dx = [];
dU_dy = [];

% Crea una griglia di punti per le finestre
[x_grid, y_grid] = meshgrid(1:overlap:(2*size(imag2_filtered, 2) - window_size), ...
                            1:overlap:(size(imag2_filtered, 1) - window_size)); 

%% Carica maschera
CREATE_MASK = 0;

if CREATE_MASK
    crea_maschera("mask_oveall", h);
end

mask = importdata('mask_oveall');


%% Cilco PIV immagini
%barra = waitbar(0, 'Processing, please wait...');

parfor k = 1: 50

    %Load images
    if k < 10
        file1A = strcat("test\"+suffix+"ms\Cam1\Cam1_000", num2str(k, '%d'), "A.b16");
        file1B = strcat("test\"+suffix+"ms\Cam1\Cam1_000", num2str(k, '%d'), "B.b16");
    else 
        file1A = strcat("test\"+suffix+"ms\Cam1\Cam1_00", num2str(k, '%d'), "A.b16");
        file1B = strcat("test\"+suffix+"ms\Cam1\Cam1_00", num2str(k, '%d'), "B.b16"); 
    end

    % Pre-processing
    imag1A_filtered = filter_image(file1A, [0.001 0.05]);
    imag1B_filtered = filter_image(file1B, [0.023 0.074]);
    

    if k<10
        file2A = strcat("test\"+suffix+"ms\Cam2\Cam2_000", num2str(k, '%d'), "A.b16");
        file2B = strcat("test\"+suffix+"ms\Cam2\Cam2_000", num2str(k, '%d'), "B.b16");
    else 
        file2A = strcat("test\"+suffix+"ms\Cam2\Cam2_00", num2str(k, '%d'), "A.b16");
        file2B = strcat("test\"+suffix+"ms\Cam2\Cam2_00", num2str(k, '%d'), "B.b16"); 
    end
    
    % Pre-processing
    imag2A_filtered = filter_image(file2A, [0.01 0.45]);
    imag2B_filtered = filter_image(file2B, [0.27 0.69]);

    % Reconstruct the two images and apply mask
    imag1_filtered = [imag2A_filtered, imag1A_filtered];
    imag1_filtered(mask) = NaN;
    imag2_filtered = [imag2B_filtered, imag1B_filtered];
    imag2_filtered(mask) = NaN;

   
    %% Algoritmo PIV
    
    % Inizializza matrici per il campo di velocità
    U = zeros(size(x_grid));
    V = zeros(size(y_grid));
    
    % Ciclo sulle finestre
    window_half_size = floor(window_size / 2);

    % Extract windows for the entire grid from both images
    for i = 1:(size(x_grid, 1))
        for j = 1:(size(x_grid,2))
            
            [U(i,j), V(i,j)] = piv_algorithm(i, j, x_grid, y_grid, magn, ...
                                            window_size, imag1_filtered, ...
                                            imag2_filtered, Deltat);
           
        end
    end
   
    % filtro gaussiano
    % U_filtered = imgaussfilt(U);
    % V_filtered = imgaussfilt(V);
    U_filtered = medfilt2(U, [3 3]);  
    V_filtered = medfilt2(V, [3 3]);  
    

    %% Post-processing
    [allU(:,:,k), allV(:,:,k), dU_dx, dV_dy] = post_processing(U_filtered, V_filtered);

    % Update the waitbar
    %waitbar(k / 50, barra, sprintf('Processing %d of %d...', k, 50))
end

% Close the waitbar once the loop is done
%close(barra);

%% Media i risultati su tutte le 50 immagini

% Media campo velocità
meanU = -mean(allU, 3,"omitnan"); 
meanV = -mean(allV, 3,"omitnan");

% Magnitude velocity
speed = sqrt(meanU.^2 + meanV.^2);

%Calcolo della vorticità
[du_dy, ~] = gradient(meanU); % Derivate di u
[~, dv_dx] = gradient(meanV); % Derivate di v
vorticity1 = dv_dx - du_dy; % Formula per la componente z della vorticità non filtered 
vorticity2 = dV_dx - dU_dy;% Formula per la componente z della vorticità filtered 

% Get the filterd and maskered image
file1 = strcat("test\"+suffix+"ms\Cam1\Cam1_0001A.b16");
file2 = strcat("test\"+suffix+"ms\Cam2\Cam2_0001A.b16");
imagCam1_filtered = filter_image(file1, [0.001 0.05]);
imagCam2_filtered = filter_image(file2, [0.01 0.45]);
image_filtered = [imagCam2_filtered, imagCam1_filtered];

%% Visualizzazione

% Quiver plot
figure()
set(gcf, 'Position', get(0, 'ScreenSize'));
imshow(image_filtered)
hold on
h = quiver(x_grid, y_grid, meanU, meanV, 'Color', 'r','AutoScaleFactor',3);
set(h, 'Color', 'r');
set(gca, 'YDir', 'reverse');
%title('Mappa di velocità media contour')
xlabel('X (pixel)')
ylabel('Y (pixel)')
hold off
%saveas(gca, strcat(strcat('post/Gruppo4/Quiver_UV_', suffix),'.svg'),'svg')

% Campo di velocità U-component
figure
set(gcf, 'Position', get(0, 'ScreenSize'));
imagesc(meanU)
%title('U component')
colormap("jet")
colorbar()
clim([-10 10])
%saveas(gca, strcat(strcat('post/Gruppo4/U_component-field_', suffix),'.svg'),'svg')

% Campo di velocità V-component
figure
set(gcf, 'Position', get(0, 'ScreenSize'));
imagesc(meanV)
%title('V component')
colormap("jet")
colorbar()
clim([-10 10])
%saveas(gca, strcat(strcat('post/Gruppo4/V_component-field_', suffix),'.svg'),'svg')

% Campo di veloictà
figure()
set(gcf, 'Position', get(0, 'ScreenSize'));
contourf(x_grid, y_grid, speed, 140, 'LineColor', 'none')
hold on
colormap(jet)
colorbar
clim([0 12])
%quiver(x_grid, y_grid, meanU, meanV, 'r', 'AutoScale', 'on') % 'r' specifies red quiver arrows
h = streamslice(x_grid, y_grid, meanU, meanV); % Generate streamlines
set(h, 'Color', 'k'); % Set the color of the streamlines to red
set(gca, 'YDir', 'reverse'); % Reverse y-axis for correct visualization
%title('Mappa di velocità media contour')
xlabel('X (pixel)')
ylabel('Y (pixel)')
hold off
%saveas(gca, strcat(strcat('post/Gruppo4/Velocity_fieldANDStramlines_', suffix),'.svg'),'svg')

% Campo di vorticità
figure()
set(gcf, 'Position', get(0, 'ScreenSize'));
contourf(x_grid, y_grid, vorticity1, 'LineColor', 'none')
colorbar
colormap(parula)
clim([-6 6])
%title('Campo di vorticità medio')
set(gca, 'YDir', 'reverse')
xlabel('X (pixel)')
ylabel('Y (pixel)')
%saveas(gca, strcat(strcat('post/Gruppo4/Vorticity_', suffix),'.svg'),'svg')

toc