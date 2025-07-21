const mongoose = require('mongoose');

const talk_schema = new mongoose.Schema({
    _id: String,
    title: String,
    url: String,
    description: String,
    duration: String,
    speakers: String,
    internalId: String,
    publishedAt: String,
    tags: [String],
    related_talk_ids: [String] // Array di ID numerici
}, { 
    collection: 'tedx_data',
    strict: false // Opzione di sicurezza per ignorare campi extra
});

module.exports = mongoose.model('talk', talk_schema);