%{ 
    Converts 3D cartesian coordinates on a spherical surface to
    geographical coordinates (latitude and longitude, in degrees)
%}

function coordsGeo = cart2geo(coordsCart)

coordsGeo.lat = 180/pi*atan2(coordsCart.kz, sqrt((coordsCart.kx.^2)+(coordsCart.ky.^2)));
coordsGeo.long = 180/pi*atan2(coordsCart.ky, coordsCart.kx); 

end