Extension { #name : 'HNode' }

{ #category : '*Service-Extractor' }
HNode >> moveTo: anHNode [

	parent remove: self.
	self announce: (HNodeRemovedEvent new
			 removedNode: self;
			 yourself).
	anHNode add: self.
	self announce: (HNodeAddedEvent new
			 newChild: self;
			 yourself)
]

{ #category : '*Service-Extractor' }
HNode >> nodeParent [

	^ parent parent 
		ifNil: [ self ]
		ifNotNil: [ self parent nodeParent ].
]
