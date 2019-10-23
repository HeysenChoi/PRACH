function [corrIFFT, time_offset] = corrIFFT(start, duration, A, B)
    A = A(start+(1:duration),1);
    Afft = fft(A);
    B = B(start+(1:duration),1);
    Bfft = fft(B);

    corr = Afft.*conj(Bfft);
    corrIFFT = abs(ifft(corr)).^2;
    time_offset = find(corrIFFT == max(corrIFFT))-1;
end

