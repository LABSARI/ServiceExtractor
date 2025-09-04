"
This class represents an incremental migration.
"
Class {
	#name : 'IncrementalMigration',
	#superclass : 'Object',
	#instVars : [
		'firstIncrement',
		'increments',
		'methodsToExtract',
		'extraction',
		'dominatedMethod',
		'candidateMethods',
		'ibea',
		'defaultMethods',
		'reverseCallGraph',
		'candidateMethodsIndex'
	],
	#classVars : [
		'Current'
	],
	#category : 'Service-Extractor-Model',
	#package : 'Service-Extractor',
	#tag : 'Model'
}

{ #category : 'accessing' }
IncrementalMigration class >> current [

	  ^ Current ifNil: [ Current := self new ]
]

{ #category : 'accessing' }
IncrementalMigration class >> reset [

	Current := nil
]

{ #category : 'as yet unclassified' }
IncrementalMigration >> allDeletedMethodsInMonolith [

	^ increments collectAsSet: [ :increment |
		  increment monolith deletedMethods ]
]

{ #category : 'computing' }
IncrementalMigration >> currentSolutions [

	^ ibea population
]

{ #category : 'accessing' }
IncrementalMigration >> defaultMethods [

	^ defaultMethods
]

{ #category : 'accessing' }
IncrementalMigration >> defaultMethods: anObject [

	defaultMethods := anObject
]

{ #category : 'computing' }
IncrementalMigration >> extract [

	| deletedMethods |
	extraction := ServiceExtractor new
		              extractMethods: methodsToExtract;
		              yourself.
	dominatedMethod := uccg dominatedMethodsFromMethods:
		                   extraction methodsToExtract.

	candidateMethods := (extraction classes values flatten select: [ :m |
		                     m isMethod and: [
			                     (dominatedMethod includes: m) not and: [
				                     (m parentType name beginsWith: 'Uc') or: [
					                     (m parentType name beginsWith: 'Service')
						                     or: [ m parentType name beginsWith: 'Dao' ] ] ] ] ])
		                    asOrderedCollection reject: [ :m |
		                    m name = '<Initializer>' ].
	deletedMethods := self allDeletedMethodsInMonolith.
	candidateMethods := candidateMethods reject: [ :m |
		                    (methodsToExtract includes: m) or: [
			                    deletedMethods includes: m ] ].
	candidateMethodsIndex := Dictionary new.
	candidateMethods withIndexDo: [ :m :i |
		candidateMethodsIndex at: m put: i ].


	defaultMethods := (candidateMethods , methodsToExtract)
		                  asOrderedCollection.


	ibea := IBEAEngine new
		        migration: self;
		        maxGenerations: 50;
		        endpoints:
			        (methodsToExtract reject: [ :m | m name = '<Initializer>' ]);
		        methodCallGraph: uccg callGraph;
		        candidateMethods: candidateMethods;
		        yourself.
	ibea run
]

{ #category : 'computing' }
IncrementalMigration >> extract: aCollectionOfMethods [

	self methodsToExtract: aCollectionOfMethods.
	self extract
]

{ #category : 'accessing' }
IncrementalMigration >> extraction [

	^ extraction
]

{ #category : 'accessing' }
IncrementalMigration >> extraction: anObject [

	extraction := anObject
]

{ #category : 'accessing' }
IncrementalMigration >> increments [

	^ increments
]

{ #category : 'accessing' }
IncrementalMigration >> increments: anObject [

	increments := anObject
]

{ #category : 'computing' }
IncrementalMigration >> indexOfMethod: m [

	^ candidateMethodsIndex at: m ifAbsent: [ -1 ]
]

{ #category : 'initialization' }
IncrementalMigration >> initialize [

	super initialize.
	increments := OrderedCollection new.
]

{ #category : 'accessing' }
IncrementalMigration >> methodsToExtract [

	^ methodsToExtract
]

{ #category : 'accessing' }
IncrementalMigration >> methodsToExtract: anObject [

	methodsToExtract := anObject
]

{ #category : 'computing' }
IncrementalMigration >> reverseCallGraph [

	^ reverseCallGraph ifNil: [
		  reverseCallGraph := Dictionary new.
		  self extraction callGraph keysAndValuesDo: [ :caller :callees |
			  callees do: [ :callee |
				  reverseCallGraph
					  at: callee
					  ifPresent: [ :c | c add: caller ]
					  ifAbsentPut: [ Set with: caller ] ] ] ]
]

{ #category : 'as yet unclassified' }
IncrementalMigration >> saveIncrementFromService: aService [

	| increment monolith |
	monolith := Monolith new.
	monolith
		deletedMethods: aService methodsToDelete;
		methods: candidateMethods \ aService movedMethods.
	increment := Increment new.
	increment
		extractedMethods: methodsToExtract;
		extractedService: aService;
		monolith: monolith.

	increments add: increment
]

{ #category : 'as yet unclassified' }
IncrementalMigration >> serviceFromSolution: aSolution [

	| aService |
	aService := Service new.

	aService
		extractedMethods: methodsToExtract;
		dominatedMethods: dominatedMethod;
		duplicatedMethods: aSolution methodsDuplicated;
		movedMethods: aSolution methodsMoved;
		candidateMethods: candidateMethods.

	^ aService
]
