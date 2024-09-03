Class {
	#name : 'MiServiceExtractorBuilder',
	#superclass : 'HSimpleVisualizationBuilder',
	#category : 'Service-Extractor',
	#package : 'Service-Extractor'
}

{ #category : 'building' }
MiServiceExtractorBuilder >> build [

	self buildService.
	super build
]

{ #category : 'building' }
MiServiceExtractorBuilder >> buildNodeFrom: anEntity with: children [

	| node |
	node := HNode new
		        name: anEntity fullDisplayString, ': ',(mapModel elementIndex at: anEntity ifAbsent: [{}]) size asString;
		        rawModel: anEntity;
		        addAll: children;
		        expand;
		        yourself.

	(mapModel elementIndex at: anEntity ifAbsent: [{}]) size > 1 ifTrue: [
		
		node color: Color red ].

	^ node
]

{ #category : 'building' }
MiServiceExtractorBuilder >> buildService [

	| classDict |
	rootNode := HNode new.
	classDict := self mapModel currentExtract.
	classDict associationsDo: [ :assoc |
		| class members |
		class := assoc key.
		members := assoc value.

		rootNode add: (self
				 buildNodeFrom: class
				 with:
				 (members collect: [ :m | self buildNodeFrom: m with: {  } ])) ]
]
