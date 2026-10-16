/* JanSahay - data and saved state: UI text (EN/HI/MR), documents, portals, schemes and eligibility rules.
   To add a scheme, add an entry to S below (id, rule function, documents, names[3], benefit[3], portal key). */
var lang=+(function(){try{return localStorage.getItem('sahayak_lang')}catch(e){return 0}})()||0,tab=1,vault=[],vaultErr=0,flash=null;
var STATES='Maharashtra,Andhra Pradesh,Arunachal Pradesh,Assam,Bihar,Chhattisgarh,Goa,Gujarat,Haryana,Himachal Pradesh,Jharkhand,Karnataka,Kerala,Madhya Pradesh,Manipur,Meghalaya,Mizoram,Nagaland,Odisha,Punjab,Rajasthan,Sikkim,Tamil Nadu,Telangana,Tripura,Uttar Pradesh,Uttarakhand,West Bengal,Delhi,Jammu & Kashmir,Ladakh,Chandigarh,Puducherry,Andaman & Nicobar,Lakshadweep,Dadra & Nagar Haveli and Daman & Diu'.split(',');
var X=[1e5,2.5e5,5e5,8e5,1e9];
var p={name:'',mob:'',state:'Maharashtra',age:20,gender:'f',inc:1,occ:'student',cat:'General',bpl:0,disab:0,preg:0,dau:0,nohouse:0,land:0,nt:0};
var saved=false,rem=[],feed=[],S=[],LV={},me=null;   /* S = schemes from the API, LV = eligibility level per scheme code */
function sv(){}   /* the profile is saved explicitly through the API */
var UI={
title:['JanSahay – schemes, documents, alerts','जनसहाय – योजनाएँ, दस्तावेज़, अलर्ट','जनसहाय – योजना, कागदपत्रे, सूचना'],
sub:['Find central and state schemes you qualify for, keep your documents in one place and apply on the official portal.','पात्र केंद्रीय और राज्य योजनाएँ खोजें, दस्तावेज़ एक जगह रखें और आधिकारिक पोर्टल पर आवेदन करें।','पात्र केंद्र व राज्य योजना शोधा, कागदपत्रे एका जागी ठेवा आणि अधिकृत पोर्टलवर अर्ज करा.'],
tabs:[['My profile','Schemes','Document vault','Alerts'],['मेरी प्रोफ़ाइल','योजनाएँ','दस्तावेज़ तिजोरी','अलर्ट'],['माझी प्रोफाइल','योजना','कागदपत्र तिजोरी','सूचना']],
name:['Full name','पूरा नाम','पूर्ण नाव'],mob:['Mobile number','मोबाइल नंबर','मोबाईल क्रमांक'],state:['State / UT','राज्य / केंद्रशासित प्रदेश','राज्य / केंद्रशासित प्रदेश'],
inc:['Yearly family income','वार्षिक पारिवारिक आय','वार्षिक कौटुंबिक उत्पन्न'],
bands:[['Below ₹1 lakh','₹1–2.5 lakh','₹2.5–5 lakh','₹5–8 lakh','Above ₹8 lakh'],['₹1 लाख से कम','₹1–2.5 लाख','₹2.5–5 लाख','₹5–8 लाख','₹8 लाख से अधिक'],['₹१ लाखाखाली','₹१–२.५ लाख','₹२.५–५ लाख','₹५–८ लाख','₹८ लाखांवर']],
age:['Age','आयु','वय'],gen:['Gender','लिंग','लिंग'],gv:[['Male','Female','Other'],['पुरुष','महिला','अन्य'],['पुरुष','महिला','इतर']],
occ:['Occupation','व्यवसाय','व्यवसाय'],ov:[['Farmer','Student','Street vendor','Worker','Homemaker','Other'],['किसान','विद्यार्थी','रेहड़ी-पटरी विक्रेता','मज़दूर','गृहिणी','अन्य'],['शेतकरी','विद्यार्थी','फेरीवाला','कामगार','गृहिणी','इतर']],
cat:['Category','वर्ग','प्रवर्ग'],
ck:{bpl:['BPL / ration card holder','बीपीएल / राशन कार्ड धारक','बीपीएल / रेशन कार्डधारक'],disab:['Person with disability','दिव्यांग व्यक्ति','दिव्यांग व्यक्ती'],preg:['Pregnant or nursing','गर्भवती या स्तनपान कराने वाली','गर्भवती किंवा स्तनदा'],dau:['Daughter under 10 years','10 वर्ष से कम की बेटी','१० वर्षांखालील मुलगी'],nohouse:['No pucca house','पक्का मकान नहीं','पक्के घर नाही'],land:['Own agricultural land','खेती की ज़मीन है','शेतजमीन आहे']},
save:['Save profile & find schemes','प्रोफ़ाइल सहेजें और योजनाएँ खोजें','प्रोफाइल जतन करा व योजना शोधा'],
sd:['Profile saved. You have','प्रोफ़ाइल सहेजी गई। आपके लिए','प्रोफाइल जतन झाली. तुमच्यासाठी'],sd2:['matching schemes.','योजनाएँ मिलीं।','योजना आढळल्या.'],
nt:['Send me notifications for new eligible schemes','नई पात्र योजनाओं की सूचना भेजें','नवीन पात्र योजनांच्या सूचना पाठवा'],
elig:['Likely eligible','संभावित पात्र','पात्र असण्याची शक्यता'],chk:['Check at office','कार्यालय में पुष्टि करें','कार्यालयात खात्री करा'],
apply:['Register / apply on official portal','आधिकारिक पोर्टल पर पंजीकरण / आवेदन','अधिकृत पोर्टलवर नोंदणी / अर्ज'],
steps:['How to apply','आवेदन कैसे करें','अर्ज कसा करावा'],
st:['Register or log in with your Aadhaar-linked mobile. Complete the portal profile. Upload documents from your vault. Submit and save the application ID.','आधार से जुड़े मोबाइल से पंजीकरण/लॉगिन करें। पोर्टल प्रोफ़ाइल पूरी करें। तिजोरी से दस्तावेज़ अपलोड करें। जमा करें और आवेदन क्रमांक सहेजें।','आधार जोडलेल्या मोबाईलने नोंदणी/लॉगिन करा. पोर्टल प्रोफाइल पूर्ण करा. तिजोरीतील कागदपत्रे अपलोड करा. सबमिट करा व अर्ज क्रमांक जतन करा.'],
ready:['documents in vault','दस्तावेज़ तिजोरी में','कागदपत्रे तिजोरीत'],
nof:['Save your profile to see matching schemes.','मेल खाती योजनाएँ देखने के लिए प्रोफ़ाइल सहेजें।','जुळणाऱ्या योजना पाहण्यासाठी प्रोफाइल जतन करा.'],
vi:['Store scanned copies (PDF, JPG or PNG, up to 4 MB each). Files are saved on the server for your account only and are not verified by any government system.','स्कैन कॉपी रखें (PDF, JPG या PNG, प्रत्येक 4 MB तक)। फ़ाइलें सर्वर पर केवल आपके खाते के लिए रखी जाती हैं और किसी सरकारी प्रणाली से सत्यापित नहीं हैं।','स्कॅन प्रती ठेवा (PDF, JPG किंवा PNG, प्रत्येकी ४ MB पर्यंत). फायली सर्व्हरवर फक्त तुमच्या खात्यासाठी जतन होतात आणि सरकारी प्रणालीने पडताळलेल्या नाहीत.'],
up:['Upload','अपलोड','अपलोड'],del:['Delete','हटाएँ','काढा'],open:['Open','खोलें','उघडा'],
rm:['Remind me on','इस दिन याद दिलाएँ','या दिवशी आठवण द्या'],setr:['Set reminder','अलर्ट लगाएँ','सूचना लावा'],
newm:['New match:','नई योजना:','नवीन योजना:'],remm:['Reminder:','अनुस्मारक:','आठवण:'],left:['days left','दिन बाकी','दिवस बाकी'],today:['Today','आज','आज'],late:['days overdue','दिन देरी','दिवस उशीर'],
none:['No alerts yet. Save your profile or set a reminder on a scheme.','अभी कोई अलर्ट नहीं। प्रोफ़ाइल सहेजें या योजना पर अलर्ट लगाएँ।','अजून सूचना नाही. प्रोफाइल जतन करा किंवा योजनेवर सूचना लावा.'],
big:['Choose a PDF, JPG or PNG under 4 MB.','4 MB से छोटी PDF, JPG या PNG चुनें।','४ MB पेक्षा लहान PDF, JPG किंवा PNG निवडा.'],
verr:['Storage is blocked in this browser, so the vault cannot save files.','इस ब्राउज़र में स्टोरेज बंद है, इसलिए तिजोरी फ़ाइलें सहेज नहीं सकती।','या ब्राउझरमध्ये स्टोरेज बंद आहे, त्यामुळे तिजोरी फायली जतन करू शकत नाही.'],
ns:['Only central schemes are listed for this state so far. State schemes are added for Maharashtra.','इस राज्य के लिए अभी केवल केंद्रीय योजनाएँ हैं। राज्य योजनाएँ अभी महाराष्ट्र के लिए हैं।','या राज्यासाठी सध्या फक्त केंद्र योजना आहेत. राज्य योजना सध्या महाराष्ट्रासाठी आहेत.'],
note:['Eligibility rules are simplified from the schemes’ published criteria and may be out of date. Always confirm on the official portal or at your CSC, Setu or ward office. Not a government service.','पात्रता नियम योजनाओं के प्रकाशित मानदंडों का सरल रूप हैं और पुराने हो सकते हैं। आवेदन से पहले आधिकारिक पोर्टल या CSC / सेतू / वार्ड कार्यालय में पुष्टि करें। यह सरकारी सेवा नहीं है।','पात्रता नियम योजनांच्या प्रकाशित निकषांचे सोपे रूप आहेत व जुने असू शकतात. अर्जापूर्वी अधिकृत पोर्टल किंवा CSC / सेतू / वॉर्ड कार्यालयात खात्री करा. ही सरकारी सेवा नाही.']};
var D={aadhaar:['Aadhaar card','आधार कार्ड','आधार कार्ड'],ration:['Ration card','राशन कार्ड','रेशन कार्ड'],ls:['Leaving certificate','स्कूल छोड़ने का प्रमाण पत्र','शाळा सोडल्याचा दाखला'],marks:['Marksheets (10th/12th/degree)','अंकपत्रिका (10वीं/12वीं/डिग्री)','गुणपत्रिका (१०वी/१२वी/पदवी)'],caste:['Caste certificate','जाति प्रमाण पत्र','जात प्रमाणपत्र'],income:['Income certificate','आय प्रमाण पत्र','उत्पन्नाचा दाखला'],domicile:['Domicile certificate','अधिवास प्रमाण पत्र','अधिवास प्रमाणपत्र'],bank:['Bank passbook','बैंक पासबुक','बँक पासबुक'],land:['Land record (7/12, 8A)','भूमि अभिलेख (7/12, 8A)','७/१२, ८अ उतारा'],udid:['Disability certificate (UDID)','दिव्यांग प्रमाण पत्र (UDID)','दिव्यांग प्रमाणपत्र (UDID)'],birth:['Birth certificate','जन्म प्रमाण पत्र','जन्म दाखला']};
function mh(p){return p.state=='Maharashtra'}
