function crea_maschera(name_save, h)
    
    image1 = "Gruppo4\9ms\Cam1\Cam1_0001A.b16";
    image2 = "Gruppo4\9ms\Cam2\Cam2_0001A.b16";

    imag1_filtered = filter_image(image1, [0.001 0.05], h);
    imag2_filtered = filter_image(image2, [0.01 0.45], h);

    image_filtered = [imag2_filtered, imag1_filtered];

    % Mostra l'immagine
    imshow(image_filtered,[]);
    title('Seleziona le zone troppo luminose');
    
    % Inizializza la maschera vuota
    combined_mask = false(size(image_filtered, 1), size(image_filtered, 2));
    
    % Loop per selezionare più poligoni
    while true
        % Usa impoly per selezionare una zona
        h = impoly; % Seleziona un poligono
        position = wait(h); % L'utente disegna il poligono e preme 'Enter' per finalizzare
        
        % Crea una maschera per il poligono selezionato
        BW = createMask(h);
        
        % Aggiungi la zona selezionata alla maschera combinata
        combined_mask = combined_mask | BW; % Unisci la maschera esistente con quella nuova
        
        % Chiedi se l'utente vuole selezionare un'altra zona
        answer = questdlg('Vuoi selezionare altra zona?', ...
            'Continua selezione', 'Yes', 'No', 'Yes');
        
        % Esci se l'utente risponde "No"
        if strcmp(answer, 'No')
            break;
        end
    end
    %%
    % Visualizza la maschera combinata
    figure;
    imshow(combined_mask);
    title('Maschera delle Zone Selezionate');
    save(name_save,"combined_mask","-mat")
    
    % Applica la maschera all'immagine (rimuovi le aree non selezionate)
    img_selected = image_filtered;
    img_selected(combined_mask) = 0; % Imposta a 0 i pixel non selezionati
    
    % Mostra l'immagine con le zone selezionate
    figure;
    imshow(img_selected);
    title('Immagine con Zone Selezionate');
end

