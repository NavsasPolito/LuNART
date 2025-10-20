function serialNumber = generateReportSerial(reportFeatures)
    % generateReportSerial generates a unique serial number for a science report
    % based on a hash of report features.

    %--- Convert report features to a string
    featuresStr = char(join(reportFeatures, ''));

    %--- Create a hash from the report features using SHA-256
    hashObj = System.Security.Cryptography.SHA256Managed;
    hash = uint8(hashObj.ComputeHash(uint8(featuresStr)));
    
    %--- Convert the hash to a hexadecimal string and take the first 10 characters
    hashHex = dec2hex(hash)';
    hashHexStr = hashHex(:)';
    shortHashHexStr = hashHexStr(1:10);

    %--- Use the short hash string as the serial number
    serialNumber = shortHashHexStr;
end