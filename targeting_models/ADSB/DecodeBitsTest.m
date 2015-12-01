% DecodeBitsTest
%   Detailed explanation goes here

% currentLat = input('Enter current latitude:  ')
% currentLong = input('Enter current longitude:  ')
currentLat = 42.3;
currentLong = -71.1;

InputBytes{1} = '8DA3CC3790C380976B152295D11F';
InputBytes{2} = '8DA3CC37994483ACB004003CB62A';
InputBytes{3} = '8d00000060c38037389c0e000000';  % From dat1090_558.mat
InputBytes{4} = '8d00000060c387be2f010e000000';
InputBytes{5} = '8D00000060C377BA050257E9ED2B';
InputBytes{6} = '8DA19E9F5017385A14972C52A6E4';
InputBytes{7} = '8DAA8A8360C377BA050257E9ED2B';
InputBytes{8} = '8DAA8A8360C370328A9D465859A0';
InputBytes{9} = '8DA66A13604B501232B9B99ADF83';
InputBytes{10} = '8DA66A13604B301276B9B184ECF9';
InputBytes{11} = '8DA19E9F5017385A14972C52A6E4';
InputBytes{12} = '8D40067860C380460CB5B2EB8D3A';
InputBytes{13} = '8D40067860C38009169B555F8602';
InputBytes{14} = '8D40067860C38791B7009F951703';
InputBytes{15} = '8D80043C68CD8091591227B39B4B';
InputBytes{16} = '8D80043C68C93048989EC9A068CA';
InputBytes{17} = '8D4B187E60C3805296A6FB255599';
InputBytes{18} = '8D4B187E60ADA797F0F8A564914B';
InputBytes{19} = '8DA6CC4190C380832AA8128A8921';
InputBytes{20} = '8DA3CC3790C380976B152295D11F';  
InputBytes{21} = '8DABDEEC99153E09802C013F4BDF';
InputBytes{22} = '8DA66A1399104CAA80A406129D1D';
InputBytes{23} = '8DAA8A83991502A7000411EE1091';
InputBytes{24} = '8D40067899050CA680050D26CFB1';
InputBytes{25} = '8D4CA74E9914C0AC80040F8D6965';
InputBytes{26} = '8D80043C9904E4A7A0070D597008';
InputBytes{27} = '8DABC6519904AFAC000513E3A869';
InputBytes{28} = '8D4B187E9944CDAAA8040F67994E';
InputBytes{29} = '8DA6CC41990488AE00070049848E';
InputBytes{30} = '8DA9BF4B99948BB0A0040E5828F0';
InputBytes{31} = '8D40067899050CA680050D26CFB1';
InputBytes{32} = '8DA3CC3790C380976B152295D11F';  % Bad results
InputBytes{33} = '8DA3CC37994483ACB004003CB62A';

for jj=1:33
    a = hex2dec(InputBytes{jj}');
    b = dec2bin(a);
    bin = reshape(b',1,length(InputBytes{jj})*4);
    InputBits = true(112,1);
    for ii=1:112
        InputBits(ii)=logical(bin2dec(bin(ii)));
    end

    [nV,eV,aV,alt,lat,long,type] = DecodeBits_ADI(InputBits, currentLat, currentLong);

    speed = sqrt(nV^2 + eV^2);

    if nV>=0
        nDir='North';
    else
        nDir='South';
    end
    if eV>=0
        eDir='East';
    else
        eDir='West';
    end
    if aV>=0
        aDir='Up';
    else
        aDir='Down';
    end

    fprintf('Aircraft ID %s      Long Message CRC: %s\n', InputBytes{jj}(3:8), InputBytes{jj});
    if type == 'L'
        fprintf('Aircraft ID %s is at altitude %6.0f\n', InputBytes{jj}(3:8), alt);
        fprintf('Aircraft ID %s is at latitude %d %d %4.1f, longitude %d %d %4.1f\n', InputBytes{jj}(3:8), degrees2dms(lat), degrees2dms(long));
    elseif type == 'A'
        fprintf('Aircraft ID %s is traveling at %f knots\nDirection %s at %f knots, direction %s at %f knots \n', InputBytes{jj}(3:8), speed, eDir, abs(eV), nDir, abs(nV));
        fprintf('Aircraft ID %s is going %s at %f feet/min\n', InputBytes{jj}(3:8), aDir, abs(aV));
    end
    fprintf('\n');
end




