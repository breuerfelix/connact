require('dotenv').config()
const express = require('express')
const MongoClient = require('mongodb').MongoClient
const jwt = require('jsonwebtoken')
const bodyParser = require('body-parser')
const cors = require('cors')

const { MONGO_URL, JWT_SECRET, PORT } = process.env

if (!MONGO_URL || !JWT_SECRET) {
	console.log('Environment variables are missing')
	process.exit(1)
}

const app = express()
const port = PORT || 80

app.use(cors())
app.use(bodyParser.urlencoded({ extended: false }))

const client = new MongoClient(MONGO_URL, { useNewUrlParser: true })
let auth, users

app.get('/search', async (req, res) => {
	const tokenHeader = req.headers.authorization
	if (!tokenHeader) {
		res.send(JSON.stringify({ error: 'Missing JWT token.' }))
		return
	}

	const tokenSplit = tokenHeader.split(" ")
	if (tokenSplit.length != 2) {
		res.send(JSON.stringify({ error: 'Auth header wrong format.' }))
		return
	}

	const token = tokenSplit[1]

	try {
		jwt.verify(token, JWT_SECRET)
	} catch {
		res.send(JSON.stringify({ error: 'Invalid credentials.' }))
		return
	}

	const username = req.query.username
	if (!username) {
		res.send(JSON.stringify({ error: 'Missing query parameter.' }))
		return
	}

	const cursor = users.aggregate([{
		$search: {
			// i configured a 'username' index in the ui
			index: "username",
			text: {
				query: username,
				path: "username",
				fuzzy: {},
			},
		},
	}])

	const matches = []
	for await (const match of cursor) {
		matches.push(match)
	}
	const filtered = matches.map(({ username, email, displayname }) => ({ username, email, displayname }))

	res.send(JSON.stringify({ matches: filtered }))
})

client.connect(err => {
	if (err) {
		console.error('error connecting to database', err)
		return
	}

	process.on('exit', () => client.close())

	auth = client.db('auth')
	users = auth.collection('users')

	app.listen(port, () => console.log(`search service listening on port ${port}!`))
})
