function err = berr(u)
    u_norm = complex(0.75 * abs(real(u)) / max(abs(real(u))), 0.75 * abs(imag(u)) / max(abs(imag(u))));
    err = sum((real(u_norm) - 0.75).^2) + sum((imag(u_norm) - 0.75).^2);
end