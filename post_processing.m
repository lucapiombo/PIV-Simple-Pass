function [allU, allV, dU_dx, dV_dy] = post_processing(U_filtered, V_filtered)

    % Calcola la distanza tra i vettori di velocità adiacenti
    distances = sqrt(diff(U_filtered,1,2).^2 + diff(V_filtered,1,2).^2);
    [dU_dx, dU_dy] = gradient(U_filtered);
    [dV_dx, dV_dy] = gradient(V_filtered);
 
    velocity_gradient = sqrt(dU_dx.^2 + dU_dy.^2 + dV_dx.^2 + dV_dy.^2);
    threshold =  mean(velocity_gradient(:))+ 3 * std(velocity_gradient(:));
    anomalous = velocity_gradient > threshold;
    U_filtered(anomalous) = NaN;
    V_filtered(anomalous) = NaN;
    
    % Imposta una soglia per la rimozione degli outlier (ad esempio, 3 volte la deviazione standard)
    threshold = mean(distances(:)) +3 * std(distances(:));

    % % Sostituisci i vettori anomali con NaN o con un valore di velocità predefinito
    U_filtered(distances > threshold) = NaN;
    V_filtered(distances > threshold) = NaN;
    max_velocity = 20; % m/s (ad esempio)
    speed = sqrt(U_filtered.^2 + V_filtered.^2);
    anomalous = speed > max_velocity;

    U_filtered(anomalous) = NaN;
    V_filtered(anomalous) = NaN;
    allU = U_filtered;
    allV = V_filtered;
end