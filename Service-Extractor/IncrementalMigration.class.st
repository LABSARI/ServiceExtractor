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
	#category : 'Service-Extractor-Model',
	#package : 'Service-Extractor',
	#tag : 'Model'
}

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

	candidateMethods := candidateMethods reject: [ :m |
		                    methodsToExtract includes: m ].
	candidateMethodsIndex := Dictionary new.
	candidateMethods withIndexDo: [ :m :i |
		candidateMethodsIndex at: m put: i ].


	defaultMethods := (candidateMethods , methodsToExtract)
		                  asOrderedCollection.


	ibea := IBEAEngine new
		        migration: self;
		        maxGenerations: 100;
		        endpoints:
			        (methodsToExtract reject: [ :m | m name = '<Initializer>' ]);
		        methodCallGraph: uccg callGraph;
		        candidateMethods: candidateMethods;
		        yourself.
	ibea run.
	
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

{ #category : 'computing' }
IncrementalMigration >> indexOfMethod: m [

	^ candidateMethodsIndex at: m ifAbsent: [ -1 ]
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
