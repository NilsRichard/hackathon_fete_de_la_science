const fs = require("fs");
const firebase = require("firebase");
require("firebase/firestore");

const firebaseConfig = JSON.parse(fs.readFileSync("firebase-config.json"));
firebase.initializeApp(firebaseConfig);

var db = firebase.firestore();

const le_json = fs.readFileSync("fr-esr-fete-de-la-science-19.json");
const data = JSON.parse(le_json);

for (d of data.slice(0,4)) {
    let el = {};
    // add some data
    el.title = d.fields.titre_fr;
    el.image = d.fields.image;
    // parse location
    console.log(d.fields.geolocalisation);
    const [lat, lon] = d.fields.geolocalisation;
    el.location = new firebase.firestore.GeoPoint(lat, lon);

    // parse date
    const regex = /^(....-..-..T..:..:..\+..:..)-(....-..-..T..:..:..\+..:..)$/;
    const found = d.fields.horaires_iso.match(regex);
    el.date_start = new Date(found[1]);
    el.date_end = new Date(found[2]);

    console.log(el);
    db.collection("programme").doc(d.fields.identifiant).set(el)
        .then(function() { console.log("success"); })
        .catch(function(error) { console.log("error:", error); });

}
