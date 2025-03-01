const express = require('express');
const app = express();

app.get('/', (req, res) => {
    res.json({ message: "Hello from Backend Node Service!" });
});

app.listen(4000, () => {
    console.log("Web server running on port 4000");
});