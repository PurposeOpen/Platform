class Country
  REGIONS = ActiveSupport::OrderedHash.new
  REGIONS['1'] = "Africa - Eastern Africa"
  REGIONS['2'] = "Africa - Middle Africa"
  REGIONS['3'] = "Africa - Northern Africa"
  REGIONS['4'] = "Africa - Southern Africa"
  REGIONS['5'] = "Africa - Western Africa"
  REGIONS['6'] = "Americas - Caribbean"
  REGIONS['7'] = "Americas - Central America"
  REGIONS['8'] = "Americas - South America"
  REGIONS['9'] = "Americas - Northern America"
  REGIONS['10'] = "Asia - Central Asia"
  REGIONS['11'] = "Asia - Eastern Asia"
  REGIONS['12'] = "Asia - Southern Asia"
  REGIONS['13'] = "Asia - South-Eastern Asia"
  REGIONS['14'] = "Asia - Western Asia"
  REGIONS['15'] = "Europe - Eastern Europe"
  REGIONS['16'] = "Europe - Northern Europe"
  REGIONS['17'] = "Europe - Southern Europe"
  REGIONS['18'] = "Europe - Western Europe"
  REGIONS['19'] = "Oceania - Australia and New Zealand"
  REGIONS['20'] = "Oceania - Melanesia"
  REGIONS['21'] = "Oceania - Micronesia"
  REGIONS['22'] = "Oceania - Polynesia"

  COUNTRIES = ActiveSupport::OrderedHash.new
  COUNTRIES["AF"] = {name: "AFGHANISTAN", zone: 3, region_id: 12, commonwealth: false}
  COUNTRIES["AL"] = {name: "ALBANIA", zone: 2, region_id: 17, commonwealth: false}
  COUNTRIES["DZ"] = {name: "ALGERIA", zone: 2, region_id: 3, commonwealth: false}
  COUNTRIES["AS"] = {name: "AMERICAN SAMOA", zone: 4, region_id: 22, commonwealth: false}
  COUNTRIES["AD"] = {name: "ANDORRA", zone: 2, region_id: 17, commonwealth: false}
  COUNTRIES["AO"] = {name: "ANGOLA", zone: 2, region_id: 2, commonwealth: false}
  COUNTRIES["AI"] = {name: "ANGUILLA", zone: 1, region_id: 6, commonwealth: false}
  COUNTRIES["AG"] = {name: "ANTIGUA AND BARBUDA", zone: 1, region_id: 6, commonwealth: true}
  COUNTRIES["AR"] = {name: "ARGENTINA", zone: 1, region_id: 8, commonwealth: false}
  COUNTRIES["AM"] = {name: "ARMENIA", zone: 3, region_id: 14, commonwealth: false}
  COUNTRIES["AW"] = {name: "ARUBA", zone: 1, region_id: 6, commonwealth: false}
  COUNTRIES["AU"] = {name: "AUSTRALIA", zone: 4, region_id: 19, commonwealth: true}
  COUNTRIES["AT"] = {name: "AUSTRIA", zone: 2, region_id: 18, commonwealth: false}
  COUNTRIES["AZ"] = {name: "AZERBAIJAN", zone: 3, region_id: 14, commonwealth: false}
  COUNTRIES["BS"] = {name: "BAHAMAS", zone: 1, region_id: 6, commonwealth: true}
  COUNTRIES["BH"] = {name: "BAHRAIN", zone: 3, region_id: 14, commonwealth: false}
  COUNTRIES["BD"] = {name: "BANGLADESH", zone: 3, region_id: 12, commonwealth: true}
  COUNTRIES["BB"] = {name: "BARBADOS", zone: 1, region_id: 6, commonwealth: true}
  COUNTRIES["BY"] = {name: "BELARUS", zone: 2, region_id: 15, commonwealth: false}
  COUNTRIES["BE"] = {name: "BELGIUM", zone: 2, region_id: 18, commonwealth: false}
  COUNTRIES["BZ"] = {name: "BELIZE", zone: 1, region_id: 7, commonwealth: true}
  COUNTRIES["BJ"] = {name: "BENIN", zone: 2, region_id: 5, commonwealth: false}
  COUNTRIES["BM"] = {name: "BERMUDA", zone: 1, region_id: 9, commonwealth: false}
  COUNTRIES["BT"] = {name: "BHUTAN", zone: 3, region_id: 12, commonwealth: false}
  COUNTRIES["BO"] = {name: "BOLIVIA", zone: 1, region_id: 8, commonwealth: false}
  COUNTRIES["BA"] = {name: "BOSNIA AND HERZEGOVINA", zone: 2, region_id: 17, commonwealth: false}
  COUNTRIES["BW"] = {name: "BOTSWANA", zone: 2, region_id: 4, commonwealth: true}
  COUNTRIES["BR"] = {name: "BRAZIL", zone: 1, region_id: 8, commonwealth: false}
  COUNTRIES["BN"] = {name: "BRUNEI DARUSSALAM", zone: 4, region_id: 13, commonwealth: true}
  COUNTRIES["BG"] = {name: "BULGARIA", zone: 2, region_id: 15, commonwealth: false}
  COUNTRIES["BF"] = {name: "BURKINA FASO", zone: 2, region_id: 5, commonwealth: false}
  COUNTRIES["BI"] = {name: "BURUNDI", zone: 2, region_id: 1, commonwealth: false}
  COUNTRIES["KH"] = {name: "CAMBODIA", zone: 4, region_id: 13, commonwealth: false}
  COUNTRIES["CM"] = {name: "CAMEROON", zone: 2, region_id: 2, commonwealth: true}
  COUNTRIES["CA"] = {name: "CANADA", zone: 1, region_id: 9, commonwealth: true}
  COUNTRIES["CV"] = {name: "CAPE VERDE", zone: 2, region_id: 5, commonwealth: false}
  COUNTRIES["KY"] = {name: "CAYMAN ISLANDS", zone: 1, region_id: 6, commonwealth: false}
  COUNTRIES["CF"] = {name: "CENTRAL AFRICAN REPUBLIC", zone: 2, region_id: 2, commonwealth: false}
  COUNTRIES["TD"] = {name: "CHAD", zone: 2, region_id: 2, commonwealth: false}
  COUNTRIES["CL"] = {name: "CHILE", zone: 1, region_id: 8, commonwealth: false}
  COUNTRIES["CN"] = {name: "CHINA", zone: 4, region_id: 11, commonwealth: false}
  COUNTRIES["CO"] = {name: "COLOMBIA", zone: 1, region_id: 8, commonwealth: false}
  COUNTRIES["KM"] = {name: "COMOROS", zone: 2, region_id: 1, commonwealth: false}
  COUNTRIES["CG"] = {name: "CONGO", zone: 2, region_id: 2, commonwealth: false}
  COUNTRIES["CD"] = {name: "CONGO THE DEMOCRATIC REPUBLIC OF THE", zone: 2, region_id: 2, commonwealth: false}
  COUNTRIES["CK"] = {name: "COOK ISLANDS", zone: 4, region_id: 22, commonwealth: true}
  COUNTRIES["CR"] = {name: "COSTA RICA", zone: 1, region_id: 7, commonwealth: false}
  COUNTRIES["CI"] = {name: "COTE D'IVOIRE", zone: 2, region_id: 5, commonwealth: false}
  COUNTRIES["HR"] = {name: "CROATIA", zone: 2, region_id: 17, commonwealth: false}
  COUNTRIES["CU"] = {name: "CUBA", zone: 1, region_id: 6, commonwealth: false}
  COUNTRIES["CY"] = {name: "CYPRUS", zone: 3, region_id: 14, commonwealth: true}
  COUNTRIES["CZ"] = {name: "CZECH REPUBLIC", zone: 2, region_id: 15, commonwealth: false}
  COUNTRIES["DK"] = {name: "DENMARK", zone: 2, region_id: 16, commonwealth: false}
  COUNTRIES["DJ"] = {name: "DJIBOUTI", zone: 2, region_id: 1, commonwealth: false}
  COUNTRIES["DM"] = {name: "DOMINICA", zone: 1, region_id: 6, commonwealth: true}
  COUNTRIES["DO"] = {name: "DOMINICAN REPUBLIC", zone: 1, region_id: 6, commonwealth: false}
  COUNTRIES["EC"] = {name: "ECUADOR", zone: 1, region_id: 8, commonwealth: false}
  COUNTRIES["EG"] = {name: "EGYPT", zone: 2, region_id: 3, commonwealth: false}
  COUNTRIES["SV"] = {name: "EL SALVADOR", zone: 1, region_id: 7, commonwealth: false}
  COUNTRIES["GQ"] = {name: "EQUATORIAL GUINEA", zone: 2, region_id: 2, commonwealth: false}
  COUNTRIES["ER"] = {name: "ERITREA", zone: 2, region_id: 1, commonwealth: false}
  COUNTRIES["EE"] = {name: "ESTONIA", zone: 2, region_id: 16, commonwealth: false}
  COUNTRIES["ET"] = {name: "ETHIOPIA", zone: 2, region_id: 1, commonwealth: false}
  COUNTRIES["FK"] = {name: "FALKLAND ISLANDS (MALVINAS)", zone: 1, region_id: 8, commonwealth: false}
  COUNTRIES["FO"] = {name: "FAROE ISLANDS", zone: 2, region_id: 16, commonwealth: false}
  COUNTRIES["FJ"] = {name: "FIJI", zone: 4, region_id: 20, commonwealth: false}
  COUNTRIES["FI"] = {name: "FINLAND", zone: 2, region_id: 16, commonwealth: false}
  COUNTRIES["FR"] = {name: "FRANCE", zone: 2, region_id: 18, commonwealth: false}
  COUNTRIES["GF"] = {name: "FRENCH GUIANA", zone: 1, region_id: 8, commonwealth: false}
  COUNTRIES["PF"] = {name: "FRENCH POLYNESIA", zone: 4, region_id: 22, commonwealth: false}
  COUNTRIES["GA"] = {name: "GABON", zone: 2, region_id: 2, commonwealth: false}
  COUNTRIES["GM"] = {name: "GAMBIA", zone: 2, region_id: 5, commonwealth: true}
  COUNTRIES["GE"] = {name: "GEORGIA", zone: 3, region_id: 14, commonwealth: false}
  COUNTRIES["DE"] = {name: "GERMANY", zone: 2, region_id: 18, commonwealth: false}
  COUNTRIES["GH"] = {name: "GHANA", zone: 2, region_id: 5, commonwealth: true}
  COUNTRIES["GI"] = {name: "GIBRALTAR", zone: 2, region_id: 17, commonwealth: false}
  COUNTRIES["GR"] = {name: "GREECE", zone: 2, region_id: 17, commonwealth: false}
  COUNTRIES["GL"] = {name: "GREENLAND", zone: 1, region_id: 9, commonwealth: false}
  COUNTRIES["GD"] = {name: "GRENADA", zone: 1, region_id: 6, commonwealth: true}
  COUNTRIES["GP"] = {name: "GUADELOUPE", zone: 1, region_id: 6, commonwealth: false}
  COUNTRIES["GU"] = {name: "GUAM", zone: 4, region_id: 21, commonwealth: false}
  COUNTRIES["GT"] = {name: "GUATEMALA", zone: 1, region_id: 7, commonwealth: false}
  COUNTRIES["GN"] = {name: "GUINEA", zone: 2, region_id: 5, commonwealth: false}
  COUNTRIES["GW"] = {name: "GUINEA-BISSAU", zone: 2, region_id: 5, commonwealth: false}
  COUNTRIES["GY"] = {name: "GUYANA", zone: 1, region_id: 8, commonwealth: true}
  COUNTRIES["HT"] = {name: "HAITI", zone: 1, region_id: 6, commonwealth: false}
  COUNTRIES["HN"] = {name: "HONDURAS", zone: 1, region_id: 7, commonwealth: false}
  COUNTRIES["HK"] = {name: "HONG KONG", zone: 4, region_id: 11, commonwealth: false}
  COUNTRIES["HU"] = {name: "HUNGARY", zone: 2, region_id: 15, commonwealth: false}
  COUNTRIES["IS"] = {name: "ICELAND", zone: 2, region_id: 16, commonwealth: false}
  COUNTRIES["IN"] = {name: "INDIA", zone: 3, region_id: 12, commonwealth: true}
  COUNTRIES["ID"] = {name: "INDONESIA", zone: 4, region_id: 13, commonwealth: false}
  COUNTRIES["IR"] = {name: "IRAN  ISLAMIC REPUBLIC OF", zone: 3, region_id: 12, commonwealth: false}
  COUNTRIES["IQ"] = {name: "IRAQ", zone: 3, region_id: 14, commonwealth: false}
  COUNTRIES["IE"] = {name: "IRELAND", zone: 2, region_id: 16, commonwealth: false}
  COUNTRIES["IL"] = {name: "ISRAEL", zone: 3, region_id: 14, commonwealth: false}
  COUNTRIES["IT"] = {name: "ITALY", zone: 2, region_id: 17, commonwealth: false}
  COUNTRIES["JM"] = {name: "JAMAICA", zone: 1, region_id: 6, commonwealth: true}
  COUNTRIES["JP"] = {name: "JAPAN", zone: 4, region_id: 11, commonwealth: false}
  COUNTRIES["JO"] = {name: "JORDAN", zone: 3, region_id: 14, commonwealth: false}
  COUNTRIES["KZ"] = {name: "KAZAKHSTAN", zone: 3, region_id: 10, commonwealth: false}
  COUNTRIES["KE"] = {name: "KENYA", zone: 2, region_id: 1, commonwealth: true}
  COUNTRIES["KI"] = {name: "KIRIBATI", zone: 4, region_id: 21, commonwealth: true}
  COUNTRIES["XK"] = {name: "KOSOVO", zone: nil, region_id: 14, commonwealth: false}
  COUNTRIES["KW"] = {name: "KUWAIT", zone: 3, region_id: 14, commonwealth: false}
  COUNTRIES["KG"] = {name: "KYRGYZSTAN", zone: 3, region_id: 10, commonwealth: false}
  COUNTRIES["LA"] = {name: "LAO PEOPLE'S DEMOCRATIC REPUBLIC", zone: 4, region_id: 13, commonwealth: false}
  COUNTRIES["LV"] = {name: "LATVIA", zone: 2, region_id: 16, commonwealth: false}
  COUNTRIES["LB"] = {name: "LEBANON", zone: 3, region_id: 14, commonwealth: false}
  COUNTRIES["LS"] = {name: "LESOTHO", zone: 2, region_id: 4, commonwealth: true}
  COUNTRIES["LR"] = {name: "LIBERIA", zone: 2, region_id: 5, commonwealth: false}
  COUNTRIES["LY"] = {name: "LIBYAN ARAB JAMAHIRIYA", zone: 2, region_id: 3, commonwealth: false}
  COUNTRIES["LI"] = {name: "LIECHTENSTEIN", zone: 2, region_id: 18, commonwealth: false}
  COUNTRIES["LT"] = {name: "LITHUANIA", zone: 2, region_id: 16, commonwealth: false}
  COUNTRIES["LU"] = {name: "LUXEMBOURG", zone: 2, region_id: 18, commonwealth: false}
  COUNTRIES["MO"] = {name: "MACAO", zone: 4, region_id: 11, commonwealth: false}
  COUNTRIES["MK"] = {name: "MACEDONIA  THE FORMER YUGOSLAV REPUBLIC OF", zone: 2, region_id: 17, commonwealth: false}
  COUNTRIES["MG"] = {name: "MADAGASCAR", zone: 2, region_id: 1, commonwealth: false}
  COUNTRIES["MW"] = {name: "MALAWI", zone: 2, region_id: 1, commonwealth: true}
  COUNTRIES["MY"] = {name: "MALAYSIA", zone: 4, region_id: 13, commonwealth: true}
  COUNTRIES["MV"] = {name: "MALDIVES", zone: 3, region_id: 12, commonwealth: true}
  COUNTRIES["ML"] = {name: "MALI", zone: 2, region_id: 5, commonwealth: false}
  COUNTRIES["MT"] = {name: "MALTA", zone: 2, region_id: 17, commonwealth: true}
  COUNTRIES["MH"] = {name: "MARSHALL ISLANDS", zone: 4, region_id: 21, commonwealth: false}
  COUNTRIES["MQ"] = {name: "MARTINIQUE", zone: 1, region_id: 6, commonwealth: false}
  COUNTRIES["MR"] = {name: "MAURITANIA", zone: 2, region_id: 5, commonwealth: false}
  COUNTRIES["MU"] = {name: "MAURITIUS", zone: 2, region_id: 1, commonwealth: true}
  COUNTRIES["YT"] = {name: "MAYOTTE", zone: 2, region_id: 1, commonwealth: false}
  COUNTRIES["MX"] = {name: "MEXICO", zone: 1, region_id: 7, commonwealth: false}
  COUNTRIES["FM"] = {name: "MICRONESIA  FEDERATED STATES OF", zone: 4, region_id: 21, commonwealth: false}
  COUNTRIES["MD"] = {name: "MOLDOVA  REPUBLIC OF", zone: 2, region_id: 15, commonwealth: false}
  COUNTRIES["MC"] = {name: "MONACO", zone: 2, region_id: 18, commonwealth: false}
  COUNTRIES["MN"] = {name: "MONGOLIA", zone: 4, region_id: 11, commonwealth: false}
  COUNTRIES["ME"] = {name: "MONTENEGRO", zone: 2, region_id: 17, commonwealth: false}
  COUNTRIES["MS"] = {name: "MONTSERRAT", zone: 1, region_id: 6, commonwealth: true}
  COUNTRIES["MA"] = {name: "MOROCCO", zone: 2, region_id: 3, commonwealth: false}
  COUNTRIES["MZ"] = {name: "MOZAMBIQUE", zone: 2, region_id: 1, commonwealth: true}
  COUNTRIES["MM"] = {name: "MYANMAR", zone: 4, region_id: 13, commonwealth: false}
  COUNTRIES["NA"] = {name: "NAMIBIA", zone: 2, region_id: 4, commonwealth: true}
  COUNTRIES["NR"] = {name: "NAURU", zone: 4, region_id: 21, commonwealth: true}
  COUNTRIES["NP"] = {name: "NEPAL", zone: 3, region_id: 12, commonwealth: false}
  COUNTRIES["NL"] = {name: "NETHERLANDS", zone: 2, region_id: 18, commonwealth: false}
  COUNTRIES["AN"] = {name: "NETHERLANDS ANTILLES", zone: 1, region_id: 18, commonwealth: false}
  COUNTRIES["NC"] = {name: "NEW CALEDONIA", zone: 4, region_id: 20, commonwealth: false}
  COUNTRIES["NZ"] = {name: "NEW ZEALAND", zone: 4, region_id: 19, commonwealth: true}
  COUNTRIES["NI"] = {name: "NICARAGUA", zone: 1, region_id: 7, commonwealth: false}
  COUNTRIES["NE"] = {name: "NIGER", zone: 2, region_id: 5, commonwealth: false}
  COUNTRIES["NG"] = {name: "NIGERIA", zone: 2, region_id: 5, commonwealth: true}
  COUNTRIES["NF"] = {name: "NORFOLK ISLAND", zone: 4, region_id: 19, commonwealth: true}
  COUNTRIES["KP"] = {name: "NORTH KOREA", zone: 4, region_id: 11, commonwealth: false}
  COUNTRIES["MP"] = {name: "NORTHERN MARIANA ISLANDS", zone: 4, region_id: 21, commonwealth: false}
  COUNTRIES["NO"] = {name: "NORWAY", zone: 2, region_id: 16, commonwealth: false}
  COUNTRIES["OM"] = {name: "OMAN", zone: 3, region_id: 14, commonwealth: false}
  COUNTRIES["PK"] = {name: "PAKISTAN", zone: 3, region_id: 12, commonwealth: true}
  COUNTRIES["PW"] = {name: "PALAU", zone: 4, region_id: 21, commonwealth: false}
  COUNTRIES["PS"] = {name: "PALESTINIAN TERRITORY  OCCUPIED", zone: 3, region_id: 14, commonwealth: false}
  COUNTRIES["PA"] = {name: "PANAMA", zone: 1, region_id: 7, commonwealth: false}
  COUNTRIES["PG"] = {name: "PAPUA NEW GUINEA", zone: 4, region_id: 20, commonwealth: true}
  COUNTRIES["PY"] = {name: "PARAGUAY", zone: 1, region_id: 8, commonwealth: false}
  COUNTRIES["PE"] = {name: "PERU", zone: 1, region_id: 8, commonwealth: false}
  COUNTRIES["PH"] = {name: "PHILIPPINES", zone: 4, region_id: 13, commonwealth: false}
  COUNTRIES["PL"] = {name: "POLAND", zone: 2, region_id: 15, commonwealth: false}
  COUNTRIES["PT"] = {name: "PORTUGAL", zone: 2, region_id: 17, commonwealth: false}
  COUNTRIES["PR"] = {name: "PUERTO RICO", zone: 1, region_id: 6, commonwealth: false}
  COUNTRIES["QA"] = {name: "QATAR", zone: 3, region_id: 14, commonwealth: false}
  COUNTRIES["RE"] = {name: "REUNION", zone: 2, region_id: 1, commonwealth: false}
  COUNTRIES["RO"] = {name: "ROMANIA", zone: 2, region_id: 15, commonwealth: false}
  COUNTRIES["RU"] = {name: "RUSSIAN FEDERATION", zone: 3, region_id: 15, commonwealth: false}
  COUNTRIES["RW"] = {name: "RWANDA", zone: 2, region_id: 1, commonwealth: true}
  COUNTRIES["SH"] = {name: "SAINT HELENA", zone: 2, region_id: 5, commonwealth: false}
  COUNTRIES["KN"] = {name: "SAINT KITTS AND NEVIS", zone: 1, region_id: 6, commonwealth: true}
  COUNTRIES["LC"] = {name: "SAINT LUCIA", zone: 1, region_id: 6, commonwealth: true}
  COUNTRIES["PM"] = {name: "SAINT PIERRE AND MIQUELON", zone: 1, region_id: 9, commonwealth: false}
  COUNTRIES["VC"] = {name: "SAINT VINCENT AND THE GRENADINES", zone: 1, region_id: 6, commonwealth: true}
  COUNTRIES["WS"] = {name: "SAMOA", zone: 4, region_id: 22, commonwealth: true}
  COUNTRIES["SM"] = {name: "SAN MARINO", zone: 2, region_id: 17, commonwealth: false}
  COUNTRIES["ST"] = {name: "SAO TOME AND PRINCIPE", zone: 2, region_id: 2, commonwealth: false}
  COUNTRIES["SA"] = {name: "SAUDI ARABIA", zone: 3, region_id: 14, commonwealth: false}
  COUNTRIES["SN"] = {name: "SENEGAL", zone: 2, region_id: 5, commonwealth: false}
  COUNTRIES["RS"] = {name: "SERBIA", zone: 2, region_id: 17, commonwealth: false}
  COUNTRIES["SC"] = {name: "SEYCHELLES", zone: 2, region_id: 1, commonwealth: true}
  COUNTRIES["SL"] = {name: "SIERRA LEONE", zone: 2, region_id: 5, commonwealth: true}
  COUNTRIES["SG"] = {name: "SINGAPORE", zone: 4, region_id: 13, commonwealth: true}
  COUNTRIES["SK"] = {name: "SLOVAKIA", zone: 2, region_id: 15, commonwealth: false}
  COUNTRIES["SI"] = {name: "SLOVENIA", zone: 2, region_id: 17, commonwealth: false}
  COUNTRIES["SB"] = {name: "SOLOMON ISLANDS", zone: 4, region_id: 20, commonwealth: true}
  COUNTRIES["SO"] = {name: "SOMALIA", zone: 2, region_id: 1, commonwealth: false}
  COUNTRIES["ZA"] = {name: "SOUTH AFRICA", zone: 2, region_id: 4, commonwealth: true}
  COUNTRIES["KR"] = {name: "SOUTH KOREA", zone: 4, region_id: 11, commonwealth: false}
  COUNTRIES["ES"] = {name: "SPAIN", zone: 2, region_id: 17, commonwealth: false}
  COUNTRIES["LK"] = {name: "SRI LANKA", zone: 3, region_id: 12, commonwealth: true}
  COUNTRIES["SD"] = {name: "SUDAN", zone: 2, region_id: 3, commonwealth: false}
  COUNTRIES["SR"] = {name: "SURINAME", zone: 1, region_id: 8, commonwealth: false}
  COUNTRIES["SZ"] = {name: "SWAZILAND", zone: 2, region_id: 4, commonwealth: true}
  COUNTRIES["SE"] = {name: "SWEDEN", zone: 2, region_id: 16, commonwealth: false}
  COUNTRIES["CH"] = {name: "SWITZERLAND", zone: 2, region_id: 18, commonwealth: false}
  COUNTRIES["SY"] = {name: "SYRIAN ARAB REPUBLIC", zone: 3, region_id: 14, commonwealth: false}
  COUNTRIES["TW"] = {name: "TAIWAN  PROVINCE OF CHINA", zone: 4, region_id: 11, commonwealth: false}
  COUNTRIES["TJ"] = {name: "TAJIKISTAN", zone: 3, region_id: 10, commonwealth: false}
  COUNTRIES["TZ"] = {name: "TANZANIA UNITED REPUBLIC OF", zone: 2, region_id: 1, commonwealth: true}
  COUNTRIES["TH"] = {name: "THAILAND", zone: 4, region_id: 13, commonwealth: false}
  COUNTRIES["TL"] = {name: "TIMOR-LESTE", zone: 4, region_id: 13, commonwealth: false}
  COUNTRIES["TG"] = {name: "TOGO", zone: 2, region_id: 5, commonwealth: false}
  COUNTRIES["TK"] = {name: "TOKELAU", zone: 4, region_id: 22, commonwealth: true}
  COUNTRIES["TO"] = {name: "TONGA", zone: 4, region_id: 22, commonwealth: true}
  COUNTRIES["TT"] = {name: "TRINIDAD AND TOBAGO", zone: 1, region_id: 6, commonwealth: true}
  COUNTRIES["TN"] = {name: "TUNISIA", zone: 2, region_id: 3, commonwealth: false}
  COUNTRIES["TR"] = {name: "TURKEY", zone: 3, region_id: 14, commonwealth: false}
  COUNTRIES["TM"] = {name: "TURKMENISTAN", zone: 3, region_id: 10, commonwealth: false}
  COUNTRIES["TC"] = {name: "TURKS AND CAICOS ISLANDS", zone: 1, region_id: 6, commonwealth: false}
  COUNTRIES["TV"] = {name: "TUVALU", zone: 4, region_id: 22, commonwealth: true}
  COUNTRIES["UG"] = {name: "UGANDA", zone: 2, region_id: 1, commonwealth: true}
  COUNTRIES["UA"] = {name: "UKRAINE", zone: 2, region_id: 15, commonwealth: false}
  COUNTRIES["AE"] = {name: "UNITED ARAB EMIRATES", zone: 3, region_id: 14, commonwealth: false}
  COUNTRIES["GB"] = {name: "UNITED KINGDOM", zone: 2, region_id: 16, commonwealth: true}
  COUNTRIES["US"] = {name: "UNITED STATES", zone: 1, region_id: 9, commonwealth: false}
  COUNTRIES["UM"] = {name: "UNITED STATES MINOR OUTLYING ISLANDS", zone: 4, region_id: 6, commonwealth: false}
  COUNTRIES["UY"] = {name: "URUGUAY", zone: 1, region_id: 8, commonwealth: false}
  COUNTRIES["UZ"] = {name: "UZBEKISTAN", zone: 3, region_id: 10, commonwealth: false}
  COUNTRIES["VU"] = {name: "VANUATU", zone: 4, region_id: 20, commonwealth: true}
  COUNTRIES["VA"] = {name: "VATICAN CITY STATE", zone: 2, region_id: 17, commonwealth: false}
  COUNTRIES["VE"] = {name: "VENEZUELA", zone: 1, region_id: 8, commonwealth: false}
  COUNTRIES["VN"] = {name: "VIET NAM", zone: 4, region_id: 13, commonwealth: false}
  COUNTRIES["VG"] = {name: "VIRGIN ISLANDS BRITISH", zone: 1, region_id: 6, commonwealth: false}
  COUNTRIES["VI"] = {name: "VIRGIN ISLANDS  U.S.", zone: 1, region_id: 6, commonwealth: false}
  COUNTRIES["WF"] = {name: "WALLIS AND FUTUNA", zone: 4, region_id: 22, commonwealth: false}
  COUNTRIES["EH"] = {name: "WESTERN SAHARA", zone: 2, region_id: 3, commonwealth: false}
  COUNTRIES["YE"] = {name: "YEMEN", zone: 3, region_id: 14, commonwealth: false}
  COUNTRIES["ZM"] = {name: "ZAMBIA", zone: 2, region_id: 1, commonwealth: true}
  COUNTRIES["ZW"] = {name: "ZIMBABWE", zone: 2, region_id: 1, commonwealth: false}

  def self.select_options
    COUNTRIES.map { |iso, country| [country[:name], country[:name]] }
  end

  def self.all_zone_codes
    COUNTRIES.map { |_, country| country[:zone] }.compact.uniq.sort
  end

  def self.zone_select_options
    self.all_zone_codes.map { |code| [code.to_s, code] }
  end

  def self.countries_in_zone(zone_code)
    COUNTRIES.find_all { |_, country| country[:zone].to_s == zone_code.to_s }.map { |iso, _| iso }
  end

  def self.iso_codes_with(attribute, values)
    Country::COUNTRIES.select{|iso_code, country| values.include?(country[attribute.to_sym].to_s) }.keys
  end

  def self.region_names_for_ids(region_ids)
    region_ids.collect {|region_id| REGIONS[region_id] }.compact
  end

end
