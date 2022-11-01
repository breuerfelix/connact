import * as dotenv from 'dotenv'
import surreal from 'surrealdb.js'
import { rm, readdir, mkdir, writeFile } from 'node:fs/promises'
import { toVCF } from './card.js'

const FOLDER = "./collections/collection-root"

dotenv.config()

const getEnvOrDie = (env) => {
  const value = process.env[env]
  if (!value) {
    process.exit(1)
  }

  return value
};

// folder structure: /var/lib/radicale/collections/collection-root/{username}/all

// .Radicale.props: {"D:displayname": "All", "tag": "VADDRESSBOOK"}
const radicaleProps = {
  "D:displayname": "All",
  "tag": "VADDRESSBOOK",
}

// user.vcf => card.js

const dbURL = getEnvOrDie("DB_URL")
const user = getEnvOrDie("DB_USER")
const pass = getEnvOrDie("DB_PASS")
const namespace = getEnvOrDie("DB_NAMESPACE")
const database = getEnvOrDie("DB_DATABASE")

async function clean() {
  const getDirectories = async source =>
    (await readdir(source, { withFileTypes: true }))
      .filter(dirent => dirent.isDirectory())
      .map(dirent => dirent.name)

  const folders = await getDirectories(FOLDER)
  for (const folder of folders) {
    await rm(`${FOLDER}/${folder}`, { recursive: true, force: true })
  }
}

async function main() {
  console.log("cleaning...")
  await clean()

  console.log("creating...")
  const db = new surreal(dbURL)
  await db.signin({ user, pass })
  await db.use(namespace, database)

  const users = await db.select("user")

  const userIDs = users.map(user => user.id)
  const userMap = users.reduce((map, user) => ({ ...map, [user.id]: user }), {})

  for (const id of userIDs) {
    const user = userMap[id]
    const userPath = `${FOLDER}/${user.username}/all`
    await mkdir(userPath, { recursive: true })
    await writeFile(`${userPath}/.Radicale.props`, JSON.stringify(radicaleProps))

    if (!user.contacts) continue

    for (const c of user.contacts) {
      const contact = userMap[c]
      if (!contact) continue

      await writeFile(`${userPath}/${contact.username}.vcf`, toVCF(contact))
    }
  }

  console.log("finished")
  process.exit(0)
}

main()
