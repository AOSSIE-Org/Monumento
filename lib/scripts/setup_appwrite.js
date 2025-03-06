const { Client, Databases, ID, RelationshipType, RelationMutate } = require('node-appwrite');
const readline = require('readline');

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

function getApiKeyFromUser() {
  return new Promise((resolve) => {
    rl.question('Please enter your Appwrite API key: ', (apiKey) => {
      resolve(apiKey);
    });
  });
}

function getProjectIdFromUser() {
  return new Promise((resolve) => {
    rl.question('Please enter your Appwrite Project ID: ', (projectId) => {
      resolve(projectId);
    });
  });
}

async function setupAppwrite() {
  try {
    console.log('Follow the steps below to setup your Appwrite project:\n');
    console.log('1. Create a new Appwrite project. Remeber the Project ID');
    console.log('2. Add Flutter platform to the project based on the decive you are testing.');
    console.log('3. Get the API Key from Settings > Overview > API credentials > View API Keys > Create API key.\n  Give the following scopes: Database[all] \n');

    console.log('Starting Appwrite project setup...');

    const apiKey = await getApiKeyFromUser();
    const projectId = await getProjectIdFromUser();

    const client = new Client()
      .setEndpoint(process.env.APPWRITE_ENDPOINT || 'https://cloud.appwrite.io/v1')
      .setProject(projectId)
      .setKey(apiKey);

    const databases = new Databases(client);

    // Use a fixed database ID instead of a unique one
    const databaseId = 'dbmonumento';
    const database = await databases.create(
      databaseId,
      'Database'
    );

    console.log('Database created successfully:', database.$id);

    console.log('Creating collections...');
    await createCollections(databases, database.$id);

    console.log('Adding sample monument data...');
    await addSampleMonumentData(databases, database.$id);

    console.log('Appwrite project setup completed successfully! 🎉');
    rl.close();
  } catch (error) {
    console.error('Error setting up Appwrite project:', error);
    rl.close();
  }
}

async function createCollections(databases, databaseId) {
  try {
    const monumentsCollection = await createMonumentsCollection(databases, databaseId);
    const localExpertsCollection = await createLocalExpertsCollection(databases, databaseId);
    const usersCollection = await createUsersCollection(databases, databaseId);
    
    await setupMonumentsAttributes(databases, databaseId, monumentsCollection.$id);
    await setupLocalExpertsAttributes(databases, databaseId, localExpertsCollection.$id);
    await setupUsersAttributes(databases, databaseId, usersCollection.$id);
    console.log('Collections created successfully:', monumentsCollection.$id);
  } catch (error) {
    console.error('Error creating collections:', error);
    throw error;
  }
}

async function createLocalExpertsCollection(databases, databaseId) {
  return await databases.createCollection(
    databaseId,
    'localExperts',  // Fixed ID matching the collection name
    'localExperts',
  );
}

async function setupLocalExpertsAttributes(databases, databaseId, collectionId) {
  // Add string attribute with validation rules (max length, required, etc.)
  await databases.createStringAttribute(
    databaseId,
    collectionId,
    'destination',
    255,  // maximum length
    true, // required field
    null, // no default value
    false // not an array type
  );

  await databases.createStringAttribute(
    databaseId,
    collectionId,
    'designation',
    255,
    true,
    null,
    false
  );

  await databases.createStringAttribute(
    databaseId,
    collectionId,
    'expertId',
    255,
    true,
    null,
    false
  );

  await databases.createUrlAttribute(
    databaseId,
    collectionId,
    'imageUrl',
    false,
    null,
    false
  );

  await databases.createStringAttribute(
    databaseId,
    collectionId,
    'name',
    255,
    true,
    null,
    false
  );

  await databases.createStringAttribute(
    databaseId,
    collectionId,
    'phoneNumber',
    50,
    false,
    null,
    false
  );
}

async function createMonumentsCollection(databases, databaseId) {
  return await databases.createCollection(
    databaseId,
    'monuments',  // Fixed ID matching the collection name
    'monuments',
  );
}

async function setupMonumentsAttributes(databases, databaseId, collectionId) {
  await databases.createStringAttribute(
    databaseId,
    collectionId,
    'city',
    255,
    false,
    null,
    false
  );

  await databases.createStringAttribute(
    databaseId,
    collectionId,
    'communityId',
    255,
    true,
    null,
    false
  );

  // Coordinates stored as array of floating point values (latitude, longitude)
  await databases.createFloatAttribute(
    databaseId,
    collectionId,
    'coordinates',
    false,
    null,
    null,
    null,
    true  // is array type
  );

  await databases.createStringAttribute(
    databaseId,
    collectionId,
    'country',
    255,
    true,
    null,
    false
  );

  await databases.createBooleanAttribute(
    databaseId,
    collectionId,
    'has3DModel',
    true,
    null,
    false
  );

  await databases.createUrlAttribute(
    databaseId,
    collectionId,
    'image',
    false,
    null,
    false
  );

  await databases.createUrlAttribute(
    databaseId,
    collectionId,
    'image_1x1_',
    false,
    null,
    false
  );

  await databases.createUrlAttribute(
    databaseId,
    collectionId,
    'images',
    false,
    null,
    true
  );

  await databases.createBooleanAttribute(
    databaseId,
    collectionId,
    'isPopular',
    true,
    null,
    false
  );

  await databases.createUrlAttribute(
    databaseId,
    collectionId,
    'modelLink',
    false,
    null,
    false
  );

  // Rating with min and max validation (0.0 to 5.0 scale)
  await databases.createFloatAttribute(
    databaseId,
    collectionId,
    'rating',
    false,
    0.0,  // minimum value
    5.0,  // maximum value
    null,
    false
  );

  await databases.createIntegerAttribute(
    databaseId,
    collectionId,
    'wikiPageId',
    false,
    null,
    null,
    null,
    false
  );

  await databases.createUrlAttribute(
    databaseId,
    collectionId,
    'wikipediaLink',
    false,
    null,
    false
  );

  await databases.createStringAttribute(
    databaseId,
    collectionId,
    'name',
    255,
    true,
    null,
    false
  );

  await databases.createRelationshipAttribute(
    databaseId,
    collectionId,
    'localExperts',
    RelationshipType.OneToMany,
    true,
    'localExperts',
    'monument',
    RelationMutate.SetNull,
  )
}

async function createUsersCollection(databases, databaseId) {
  return await databases.createCollection(
    databaseId,
    'users',  // Fixed ID matching the collection name
    'users',
  );
}

async function setupUsersAttributes(databases, databaseId, collectionId) {
  
  await databases.createStringAttribute(
    databaseId,
    collectionId,
    'name',
    255,
    true,
    null,
    false
  );

  await databases.createEmailAttribute(
    databaseId,
    collectionId,
    'email',
    true,
    null,
    false
  );

  await databases.createUrlAttribute(
    databaseId,
    collectionId,
    'profilePictureUrl',
    false,
    null,
    false
  );

  await databases.createStringAttribute(
    databaseId,
    collectionId,
    'status',
    255,
    false,
    null,
    false
  );

  await databases.createStringAttribute(
    databaseId,
    collectionId,
    'username',
    50,
    true,
    null,
    false
  );

  await databases.createStringAttribute(
    databaseId,
    collectionId,
    'searchParams',
    255,
    false,
    null,
    true // is array
  );

  await databases.createRelationshipAttribute(
    databaseId,
    collectionId,
    'monuments',
    RelationshipType.ManyToMany,
    false,
    'savedMonuments',
    null,
    RelationMutate.SetNull
  );

  await databases.createStringAttribute(
    databaseId,
    collectionId,
    'followers',
    255,
    false,
    null,
    true
  )

  await databases.createStringAttribute(
    databaseId,
    collectionId,
    'following',
    255,
    false,
    null,
    true
  )

  console.log('Waiting for user collection indexes to be ready...');
  await new Promise(resolve => setTimeout(resolve, 3000));
  
}

async function addSampleMonumentData(databases, databaseId) {
  try {
    console.log('Adding sample monument data...');

    // Wait to ensure indexes are created before adding documents
    console.log('Waiting for collections to be fully ready...');
    await new Promise(resolve => setTimeout(resolve, 5000));

    // Since we're now using fixed IDs, we can directly use them without querying
    const monumentsCollectionId = 'monuments';
    const localExpertsCollectionId = 'localExperts';
    const usersCollectionId = 'users';

    console.log('Using monuments collection ID:', monumentsCollectionId);
    console.log('Using localExperts collection ID:', localExpertsCollectionId);
    console.log('Using users collection ID:', usersCollectionId);

    // Sample monument data matching the schema defined in setupMonumentsAttributes
    const monumentData = {
      city: "NA",
      communityId: "8zDOMVBZHO38gGLODH1d",
      coordinates: [43.8789472, -103.459825],
      country: "South Dakota",
      has3DModel: true,
      image: "https://firebasestorage.googleapis.com/v0/b/monumento-277103.appspot.com/o/monuments%2FRushmore.png?alt=media&token=a33ee419-70ae-4c2c-bd20-091ff49f668f",
      image_1x1_: "https://firebasestorage.googleapis.com/v0/b/monumento-277103.appspot.com/o/monuments%2FRushmore.png?alt=media&token=a33ee419-70ae-4c2c-bd20-091ff49f668f",
      images: [
        "https://i0.wp.com/gregdisch.com/wp-content/uploads/2021/01/Mount-Rushmore-National-Memorial-20140915-_MG_7930.jpg?ssl=1",
        "https://www.nps.gov/moru/learn/historyculture/images/Hall-of-Records-2017-2_1.jpg?maxwidth=1300&maxheight=1300&autorotate=false",
        "https://regal-holidays.net/wp-content/uploads/2019/07/hawa-mahal-441563_1920.jpg",
        "https://regal-holidays.net/wp-content/uploads/2019/07/architecture-3187940_1920.jpg"
      ],
      isPopular: true,
      modelLink: "https://firebasestorage.googleapis.com/v0/b/monumento-277103.appspot.com/o/3dModels%2Fmount_rushmore%2Fscene?alt=media&token=522ada26-b7ae-4ef0-b682-dc595d6bf732",
      name: "Mount Rushmore National Memorial",
      rating: 3.9,
      wikiPageId: 185973,
      wikipediaLink: "https://en.wikipedia.org/wiki/Mount_Rushmore"
    };

    const createdDocument = await databases.createDocument(
      databaseId,
      monumentsCollectionId,  // Using the fixed ID
      ID.unique(),
      monumentData
    );

    console.log('Sample monument document created successfully:', createdDocument.$id);

    // Create local experts that relate to the monument by destination name
    const localExperts = [
      {
        destination: "Mount Rushmore National Memorial",
        designation: "Local Guide",
        expertId: "A98DB973KW",
        imageUrl: "https://tse4.mm.bing.net/th?id=OIP.dv5bNWXzayD0yiL_-sKuuwHaHa&pid=Api",
        name: "Thomas Baker",
        phoneNumber: "+911234567890"
      },
      {
        destination: "Mount Rushmore National Memorial",
        designation: "Freelance Photographer",
        expertId: "NKCRKENUII",
        imageUrl: "https://tse4.mm.bing.net/th?id=OIP.dv5bNWXzayD0yiL_-sKuuwHaHa&pid=Api",
        name: "Andrew Harris",
        phoneNumber: "+910987654321"
      }
    ];

    for (const expert of localExperts) {
      const createdExpert = await databases.createDocument(
        databaseId,
        localExpertsCollectionId,  // Using the fixed ID
        ID.unique(),
        expert
      );
      console.log(`Local expert document created successfully: ${createdExpert.$id}`);
    }

    // Add sample user data - updated with new attributes
    const userData = {
      name: "John Doe",
      email: "user@example.com",
      profilePictureUrl: "https://ui-avatars.com/api/?name=John+Doe&background=random",
      status: "Active explorer",
      username: "johndoe",
      searchParams: ["history", "architecture", "travel"],
      savedMonuments: [createdDocument.$id]
    };

    const createdUser = await databases.createDocument(
      databaseId,
      usersCollectionId,
      ID.unique(),
      userData
    );

    console.log('Sample user document created successfully:', createdUser.$id);

    // Create a second user for demonstrating relationships
    const userData2 = {
      name: "Jane Smith",
      email: "jane@example.com",
      profilePictureUrl: "https://ui-avatars.com/api/?name=Jane+Smith&background=random",
      status: "Monument enthusiast",
      username: "janesmith",
      searchParams: ["culture", "photography", "heritage"],
      savedMonuments: []
    };

    const createdUser2 = await databases.createDocument(
      databaseId,
      usersCollectionId,
      ID.unique(),
      userData2
    );

    console.log('Second sample user document created successfully:', createdUser2.$id);

  } catch (error) {
    console.error('Error adding sample monument data:', error);
    throw error;
  }
}

setupAppwrite();
