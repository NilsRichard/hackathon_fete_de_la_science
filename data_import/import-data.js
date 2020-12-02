const fs = require("fs");
const firebase = require("firebase");
require("firebase/firestore");

const firebaseConfig = JSON.parse(fs.readFileSync("firebase-config.json"));
firebase.initializeApp(firebaseConfig);

var db = firebase.firestore();

const le_json = fs.readFileSync("fr-esr-fete-de-la-science-19.json");
const data = JSON.parse(le_json);

locations = new Map();

var nbEvent = 0;

for (const d of data.slice(0,30)) {
    let el = {};
    // debug
    //console.log(d.fields);
    // add some data
    el.title = d.fields.titre_fr;
    el.description = d.fields.description_fr;
    el.description_long = d.fields.description_longue_fr;
    el.image = d.fields.image;
    el.image_thumb = d.fields.apercu;
    el.image_full = d.fields.image_source;
    el.link = d.fields.lien;
    el.link_canonical = d.fields.lien_canonique;
    el.registration_required = d.fields.inscription_necessaire && d.fields.inscription_necessaire.toLowerCase() == "oui";
    //console.log(d.fields.inscription_necessaire, el.registration_required);
    // parse registration links
    if (d.fields.lien_d_inscription) {
        for (const l of d.fields.lien_d_inscription.split(", ")) {
            if (l.match(/[-. ]*([0-9][-. ]*)+/)) {
                phone = l.replace(/[-. ]/g, "");
                //console.log("=> PHONE:", phone);
                if (!el.registration_phone) {
                    el.registration_phone = [];
                }
                el.registration_phone.push(phone);
            }
            else if (l.includes("@")) {
                //console.log("=> EMAIL:", l);
                if (!el.registration_email) {
                    el.registration_email = [];
                }
                el.registration_email.push(l);
            }
            else if (l.includes("://")) {
                //console.log("=> LINK:", l);
                if (!el.registration_link) {
                    el.registration_link = [];
                }
                el.registration_link.push(l);
            }
            else if (l == "") {
                // there are some events with an empty link, skip these
                // (médiathèque de Pontivy)
                //console.log(d.fields.lien_d_inscription);
                //console.log("=> EMPTY LINK");
            }
            else {
                throw "unknown registration link type: " + l;
            }
        }
    }
    // parse location
    if (!d.fields.geolocalisation) {
        // skip items without location data
        console.log("Skipping event without location:", d.fields.identifiant, d.fields.titre_fr);
        continue;
    }
    //console.log(d.fields.geolocalisation);
    const [lat, lon] = d.fields.geolocalisation;
    el.location = new firebase.firestore.GeoPoint(lat, lon);
    // location metadata
    el.location_id = d.fields.identifiant_du_lieu;
    locations.set(el.location_id, {
        name: d.fields.nom_du_lieu,
        address: d.fields.adresse,
        department: d.fields.departement,
        country: d.fields.pays,
        image: d.fields.image_du_lieu,
        image_credits: d.fields.credits_de_l_image_du_lieu,
        website: d.fields.site_web_du_lieu,
        phone: d.fields.telephone_du_lieu,
        location: el.location
    });

    // parse date
    const regex = /^(....-..-..T..:..:..([-+]..:..|Z))-(....-..-..T..:..:..([-+]..:..|Z))$/;
    el.dates = []
    for (const horaire of d.fields.horaires_iso.split("\r\n")) {
        const found = horaire.match(regex);
        el.dates.push({start: new Date(found[1]), end: new Date(found[3])});
    }

    // parse keywords
    if (d.fields.mots_cles_fr) {
        el.keywords = d.fields.mots_cles_fr.split(",");
    }

    // parse themes
    if (d.fields.thematiques) {
        el.themes = d.fields.thematiques.split("|");
    }

    //console.log(el);
    Object.keys(el).forEach(key => el[key] === undefined ? delete el[key] : {});
    /*
    db.collection("programme").doc(d.fields.identifiant).set(el)
        .then(function() { console.log("success event", d.fields.identifiant); })
        .catch(function(error) { console.log("error:", error); });
        //*/

    nbEvent++;
}

console.log("event#:", nbEvent);
console.log("location#:", locations.size);

for (const l of locations) {
    Object.keys(l[1]).forEach(key => l[1][key] === undefined ? delete l[1][key] : {});
    //console.log(l);
    /*
    db.collection("locations_test").doc(l[0]).set(l[1])
        .then(function() { console.log("success location",l[0]); })
        .catch(function(error) { console.log("error:", error); });
        //*/
}
