const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');

const app = express();
const port = 3000;

app.use(cors());
app.use(bodyParser.json());

// In-memory storage for activities
let activities = [];

// GET /activities - Retrieve all activities
app.get('/activities', (req, res) => {
    res.json(activities);
});

// POST /activities - Create a new activity
app.post('/activities', (req, res) => {
    const activity = req.body;

    // Basic validation
    if (!activity.id || !activity.timestamp) {
        return res.status(400).json({ error: 'Invalid activity data. ID and timestamp are required.' });
    }

    activities.push(activity);
    console.log('Activity added:', activity);
    res.status(201).json(activity);
});

// DELETE /activities/:id - Delete an activity by ID
app.delete('/activities/:id', (req, res) => {
    const { id } = req.params;
    const initialLength = activities.length;
    activities = activities.filter(a => a.id !== id);

    if (activities.length < initialLength) {
        console.log(`Activity ${id} deleted.`);
        res.status(200).json({ message: 'Activity deleted successfully' });
    } else {
        res.status(404).json({ error: 'Activity not found' });
    }
});

app.listen(port, () => {
    console.log(`SmartTracker backend running at http://localhost:${port}`);
});
