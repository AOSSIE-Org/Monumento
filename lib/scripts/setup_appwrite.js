const { Client, Databases, ID, RelationshipType, RelationMutate, Permission, Role, Storage, Query } = require('node-appwrite');
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
    console.log('3. Get the API Key from Settings > Overview > API credentials > View API Keys > Create API key.\n  Give the following scopes: Database[all] Storage[all] \n');

    console.log('Starting Appwrite project setup...');

    const apiKey = await getApiKeyFromUser();
    const projectId = await getProjectIdFromUser();

    const client = new Client()
      .setEndpoint(process.env.APPWRITE_API_ENDPOINT || 'https://cloud.appwrite.io/v1')
      .setProject(projectId)
      .setKey(apiKey);

    const databases = new Databases(client);
    const storage = new Storage(client);

    const databaseId = 'dbmonumento';
    let database;

    // Check if database exists before trying to create it
    try {
      database = await databases.get(databaseId);
      console.log('Found existing database:', database.$id);
    } catch (error) {
      if (error.code === 404) {
        // Database doesn't exist, create it
        database = await databases.create(databaseId, 'Database');
        console.log('Database created successfully:', database.$id);
      } else {
        console.error('Error checking database:', error);
        throw error;
      }
    }

    console.log('Creating collections if they don\'t exist...');
    await createCollectionsIdempotent(databases, database.$id);

    console.log('Creating storage bucket for images if it doesn\'t exist...');
    await createImageBucketIdempotent(storage);

    console.log('Adding sample monument data...');
    await addSampleMonumentDataIdempotent(databases, database.$id);

    console.log('Appwrite project setup completed successfully! 🎉');
    rl.close();
  } catch (error) {
    console.error('Error setting up Appwrite project:', error);
    rl.close();
  }
}

// New function to create bucket if it doesn't exist
async function createImageBucketIdempotent(storage) {
  try {
    const bucketId = 'bucketmonumento';
    try {
      await storage.getBucket(bucketId);
      console.log('Storage bucket already exists');
    } catch (error) {
      if (error.code === 404) {
        await createImageBucket(storage);
      } else {
        throw error;
      }
    }
  } catch (error) {
    console.error('Error creating storage bucket:', error);
    throw error;
  }
}

// New function to create collections if they don't exist
async function createCollectionsIdempotent(databases, databaseId) {
  try {
    // Get existing collections
    const existingCollections = await databases.listCollections(databaseId);
    const existingCollectionIds = existingCollections.collections.map(c => c.$id);

    console.log('Existing collections:', existingCollectionIds);

    // CREATE LOCALEXPERTS COLLECTION FIRST
    if (!existingCollectionIds.includes('localExperts')) {
      console.log('Creating localExperts collection...');
      const localExpertsCollection = await createLocalExpertsCollection(databases, databaseId);
      console.log('LocalExperts collection created with ID:', localExpertsCollection.$id);
      
      // Setup attributes with retry mechanism
      await setupCollectionWithRetry(databases, databaseId, localExpertsCollection.$id, setupLocalExpertsAttributes);
    } else {
      console.log('Collection localExperts already exists');
    }

    // THEN CREATE MONUMENTS COLLECTION
    if (!existingCollectionIds.includes('monuments')) {
      console.log('Creating monuments collection...');
      const monumentsCollection = await createMonumentsCollection(databases, databaseId);
      console.log('Monuments collection created with ID:', monumentsCollection.$id);
      
      // Setup attributes with retry mechanism
      await setupCollectionWithRetry(databases, databaseId, monumentsCollection.$id, setupMonumentsAttributes);
    } else {
      console.log('Collection monuments already exists');
    }

    // CREATE USERS COLLECTION
    if (!existingCollectionIds.includes('users')) {
      console.log('Creating users collection...');
      const usersCollection = await createUsersCollection(databases, databaseId);
      console.log('Users collection created with ID:', usersCollection.$id);
      
      // Setup attributes with retry mechanism
      await setupCollectionWithRetry(databases, databaseId, usersCollection.$id, setupUsersAttributes);
    } else {
      console.log('Collection users already exists');
    }
    
    // CREATE CHECKINS COLLECTION AFTER USERS
    if (!existingCollectionIds.includes('checkIns')) {
      console.log('Creating checkIns collection...');
      const checkInsCollection = await createCheckInsCollection(databases, databaseId);
      console.log('CheckIns collection created with ID:', checkInsCollection.$id);
      
      // Setup attributes with retry mechanism
      await setupCollectionWithRetry(databases, databaseId, checkInsCollection.$id, setupCheckInsAttributes);
    } else {
      console.log('Collection checkIns already exists');
    }

    // CREATE POSTS COLLECTION
    if (!existingCollectionIds.includes('posts')) {
      console.log('Creating posts collection...');
      const postsCollection = await createPostsCollection(databases, databaseId);
      console.log('Posts collection created with ID:', postsCollection.$id);
      
      // Setup attributes with retry mechanism
      await setupCollectionWithRetry(databases, databaseId, postsCollection.$id, setupPostsAttributes);
    } else {
      console.log('Collection posts already exists');
    }
    
  } catch (error) {
    console.error('Error creating collections:', error);
    throw error;
  }
}

// Helper function for setup with retry mechanism
async function setupCollectionWithRetry(databases, databaseId, collectionId, setupFn) {
  console.log('Waiting for collection to be ready (10 seconds)...');
  await new Promise(resolve => setTimeout(resolve, 10000));
  
  let retries = 3;
  let success = false;
  
  while (retries > 0 && !success) {
    try {
      console.log(`Setting up attributes (attempts left: ${retries})...`);
      await setupFn(databases, databaseId, collectionId);
      console.log('Collection attributes configured successfully');
      success = true;
    } catch (error) {
      if (error.code === 404) {
        console.log(`Collection not ready yet, retrying in 5 seconds... (${retries-1} attempts left)`);
        await new Promise(resolve => setTimeout(resolve, 5000));
        retries--;
      } else {
        throw error;
      }
    }
  }
  
  if (!success) {
    throw new Error('Failed to set up attributes after multiple retries');
  }
}

// Add the missing createUsersCollection function
async function createUsersCollection(databases, databaseId) {
  return await databases.createCollection(
    databaseId,
    'users',
    'users',
    [
      Permission.read(Role.guests()),
      Permission.read(Role.users()),
      Permission.create(Role.guests()),
      Permission.write(Role.users())
    ]
  );
}

// Add this new function for checkIns collection
async function createCheckInsCollection(databases, databaseId) {
  return await databases.createCollection(
    databaseId,
    'checkIns',
    'checkIns',
    [
      Permission.read(Role.users()),
      Permission.create(Role.users()),
      Permission.write(Role.users())
    ]
  );
}

// Add this new function for checkIns attributes
async function setupCheckInsAttributes(databases, databaseId, collectionId) {
  await databases.createStringAttribute(
    databaseId,
    collectionId,
    'monumentId',
    255,
    true
  );
  
  await databases.createStringAttribute(
    databaseId,
    collectionId,
    'title',
    255,
    false
  );
  
  await databases.createDatetimeAttribute(
    databaseId,
    collectionId,
    'timeStamp',
    true,
    null,
    false
  );
  
  await databases.createRelationshipAttribute(
    databaseId,
    collectionId,
    'users',
    RelationshipType.ManyToOne,
    true,
    'userId',
    'checkIns',
    RelationMutate.Cascade
  );
  
  console.log('CheckIns collection attributes configured successfully');
}

// New function to check if data exists before adding
async function addSampleMonumentDataIdempotent(databases, databaseId) {
  try {
    console.log('Adding sample monument data...');

    // Wait to ensure indexes are created before adding documents
    console.log('Waiting for collections to be fully ready...');
    await new Promise(resolve => setTimeout(resolve, 5000));

    // Check if monument with the same name already exists
    const monumentName = "Mount Rushmore National Memorial";

    try {
      const existingMonuments = await databases.listDocuments(
        databaseId,
        'monuments',
        [Query.equal('name', monumentName)] // Use Query.equal instead of Databases.queries.equal
      );

      if (existingMonuments.documents.length > 0) {
        console.log('Monument already exists:', existingMonuments.documents[0].$id);
      } else {
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
          name: monumentName,
          rating: 3.9,
          wikiPageId: '185973',
          wikipediaLink: "https://en.wikipedia.org/wiki/Mount_Rushmore"
        };

        const createdDocument = await databases.createDocument(
          databaseId,
          'monuments',
          ID.unique(),
          monumentData
        );

        console.log('Sample monument document created successfully:', createdDocument.$id);
      }

      // Check for existing local experts
      const existingExperts = await databases.listDocuments(
        databaseId,
        'localExperts',
        [Query.equal('destination', monumentName)] // Use Query.equal here too
      );

      const existingExpertIds = existingExperts.documents.map(e => e.expertId);
      console.log('Existing expert IDs:', existingExpertIds);

      // Local experts to add if they don't exist
      const localExperts = [
        {
          destination: monumentName,
          designation: "Local Guide",
          expertId: "A98DB973KW",
          imageUrl: "https://tse4.mm.bing.net/th?id=OIP.dv5bNWXzayD0yiL_-sKuuwHaHa&pid=Api",
          name: "Thomas Baker",
          phoneNumber: "+911234567890"
        },
        {
          destination: monumentName,
          designation: "Freelance Photographer",
          expertId: "NKCRKENUII",
          imageUrl: "https://tse4.mm.bing.net/th?id=OIP.dv5bNWXzayD0yiL_-sKuuwHaHa&pid=Api",
          name: "Andrew Harris",
          phoneNumber: "+910987654321"
        }
      ];

      // Add only experts that don't exist yet
      for (const expert of localExperts) {
        if (!existingExpertIds.includes(expert.expertId)) {
          const createdExpert = await databases.createDocument(
            databaseId,
            'localExperts',
            ID.unique(),
            expert
          );
          console.log(`Local expert document created successfully: ${createdExpert.$id}`);
        } else {
          console.log(`Local expert with ID ${expert.expertId} already exists, skipping`);
        }
      }

    } catch (error) {
      console.error('Error checking for existing documents:', error);
      throw error;
    }
  } catch (error) {
    console.error('Error adding sample monument data:', error);
    throw error;
  }
}

async function createImageBucket(storage) {
  try {
    const bucketId = 'bucketmonumento';
    const bucket = await storage.createBucket(
      bucketId,
      'Images Bucket',
      [
        Permission.read(Role.any()),
        Permission.read(Role.guests()),
        Permission.read(Role.users()),
        Permission.create(Role.users()),
        Permission.update(Role.users()),
        Permission.delete(Role.users())
      ],
      false, // file securit
      true, // enabled
      10 * 1024 * 1024, // 10MB max file size
      ['jpg', 'jpeg', 'png', 'gif', 'webp']
    );

    console.log('Storage bucket created successfully:', bucket.$id);
    return bucket;
  } catch (error) {
    console.error('Error creating storage bucket:', error);
    throw error;
  }
}

async function createLocalExpertsCollection(databases, databaseId) {
  return await databases.createCollection(
    databaseId,
    'localExperts',  // Fixed ID matching the collection name
    'localExperts',
    [
      Permission.read(Role.any()),
      Permission.read(Role.guests()),
      Permission.read(Role.users()),
    ]
  );
}

async function setupLocalExpertsAttributes(databases, databaseId, collectionId) {
  // Add string attribute with validation rules (max length, required, etc.)
  await databases.createStringAttribute(
    databaseId,
    collectionId,
    'destination',
    255,
    true,
    null,
    false
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
    'monuments',
    'monuments',
    [
      Permission.read(Role.any()),
      Permission.read(Role.guests()),
      Permission.read(Role.users()),
      Permission.create(Role.users()),
    ]
  );
}

async function setupMonumentsAttributes(databases, databaseId, collectionId) {
  // First, check which attributes already exist
  try {
    const existingAttributes = await databases.listAttributes(databaseId, collectionId);
    const existingAttributeKeys = existingAttributes.attributes.map(attr => attr.key);
    console.log(`Existing attributes for collection ${collectionId}:`, existingAttributeKeys);

    // Helper function to create attribute only if it doesn't exist
    async function createAttributeIfNotExists(attributeKey, createFn) {
      if (!existingAttributeKeys.includes(attributeKey)) {
        console.log(`Creating attribute: ${attributeKey}`);
        await createFn();
      } else {
        console.log(`Attribute ${attributeKey} already exists, skipping`);
      }
    }

    // Now create each attribute only if it doesn't exist
    await createAttributeIfNotExists('city', () =>
      databases.createStringAttribute(
        databaseId,
        collectionId,
        'city',
        255,
        false,
        null,
        false
      )
    );

    await createAttributeIfNotExists('communityId', () =>
      databases.createStringAttribute(
        databaseId,
        collectionId,
        'communityId',
        255,
        true,
        null,
        false
      )
    );

    await createAttributeIfNotExists('coordinates', () =>
      databases.createFloatAttribute(
        databaseId,
        collectionId,
        'coordinates',
        false,
        null,
        null,
        null,
        true  // is array type
      )
    );

    await createAttributeIfNotExists('country', () =>
      databases.createStringAttribute(
        databaseId,
        collectionId,
        'country',
        255,
        true,
        null,
        false
      )
    );

    await createAttributeIfNotExists('has3DModel', () =>
      databases.createBooleanAttribute(
        databaseId,
        collectionId,
        'has3DModel',
        true,
        null,
        false
      )
    );

    await createAttributeIfNotExists('image', () =>
      databases.createUrlAttribute(
        databaseId,
        collectionId,
        'image',
        false,
        null,
        false
      )
    );

    await createAttributeIfNotExists('image_1x1_', () =>
      databases.createUrlAttribute(
        databaseId,
        collectionId,
        'image_1x1_',
        false,
        null,
        false
      )
    );

    await createAttributeIfNotExists('images', () =>
      databases.createUrlAttribute(
        databaseId,
        collectionId,
        'images',
        false,
        null,
        true
      )
    );

    await createAttributeIfNotExists('isPopular', () =>
      databases.createBooleanAttribute(
        databaseId,
        collectionId,
        'isPopular',
        true,
        null,
        false
      )
    );

    await createAttributeIfNotExists('modelLink', () =>
      databases.createUrlAttribute(
        databaseId,
        collectionId,
        'modelLink',
        false,
        null,
        false
      )
    );

    await createAttributeIfNotExists('rating', () =>
      databases.createFloatAttribute(
        databaseId,
        collectionId,
        'rating',
        false,
        0.0,
        5.0,
        null,
        false
      )
    );

    await createAttributeIfNotExists('wikiPageId', () =>
      databases.createStringAttribute(
        databaseId,
        collectionId,
        'wikiPageId',
        255,
        false,
        null,
        false
      )
    );

    await createAttributeIfNotExists('wikipediaLink', () =>
      databases.createUrlAttribute(
        databaseId,
        collectionId,
        'wikipediaLink',
        false,
        null,
        false
      )
    );

    await createAttributeIfNotExists('name', () =>
      databases.createStringAttribute(
        databaseId,
        collectionId,
        'name',
        255,
        true,
        null,
        false
      )
    );

    await createAttributeIfNotExists('localExperts', () =>
      databases.createRelationshipAttribute(
        databaseId,
        collectionId,
        'localExperts',
        RelationshipType.OneToMany,
        true,
        'localExperts',
        'monument',
        RelationMutate.SetNull
      )
    );

    console.log('All attributes for monuments collection have been set up or verified');

  } catch (error) {
    console.error(`Error setting up attributes for collection ${collectionId}:`, error);
    throw error;
  }
  
  // Return the collection ID
  return collectionId;
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

  await databases.createStringAttribute(
    databaseId,
    collectionId,
    'uid',
    255,
    true
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

  await databases.createStringAttribute(
    databaseId,
    collectionId,
    'posts',
    255,
    false,
    null,
    true,
  )

  console.log('Waiting for user collection indexes to be ready...');
  await new Promise(resolve => setTimeout(resolve, 3000));

}

async function createPostsCollection(databases, databaseId) {
  return await databases.createCollection(
    databaseId,
    'posts',
    'posts',
    [
      Permission.read(Role.any()),
      Permission.read(Role.guests()),
      Permission.read(Role.users()),
      Permission.write(Role.users()),
    ]
  )
}

async function setupPostsAttributes(databases, databaseId, collectionId) {
  // Title of the post
  await databases.createStringAttribute(
    databaseId,
    collectionId,
    'title',
    255,
    true,  // required
    null,
    false
  );

  // Location of the post
  await databases.createStringAttribute(
    databaseId,
    collectionId,
    'location',
    255,
    false,
    null,
    false
  );

  // Image URL for the post
  await databases.createUrlAttribute(
    databaseId,
    collectionId,
    'imageUrl',
    false,
    null,
    false
  );

  // Timestamp for when the post was created
  await databases.createDatetimeAttribute(
    databaseId,
    collectionId,
    'timeStamp',
    true,
    null,
    false
  );

  // Type of post
  await databases.createIntegerAttribute(
    databaseId,
    collectionId,
    'postType',
    true,
    null,
    null,
    null,
    false
  );

  // User ID who created the post
  await databases.createStringAttribute(
    databaseId,
    collectionId,
    'postByUid',
    255,
    true,
    null,
    false
  );

  // Count of likes on the post
  await databases.createIntegerAttribute(
    databaseId,
    collectionId,
    'likesCount',
    true,
    0,
    null,
    null,
    false
  );

  // Count of comments on the post
  await databases.createIntegerAttribute(
    databaseId,
    collectionId,
    'commentsCount',
    true,
    0,
    null,
    null,
    false
  );

  // Create a relationship between posts and users
  await databases.createRelationshipAttribute(
    databaseId,
    collectionId,
    'users',
    RelationshipType.ManyToOne,
    false,
    'author',
    null,
    RelationMutate.SetNull
  );

  await new Promise(resolve => setTimeout(resolve, 3000));
}

setupAppwrite();
