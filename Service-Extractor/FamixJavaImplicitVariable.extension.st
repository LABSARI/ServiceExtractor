Extension { #name : 'FamixJavaImplicitVariable' }

{ #category : '*Service-Extractor' }
FamixJavaImplicitVariable >> callGraphLabel [

	^ String streamContents: [ :s |
		  | type |
		  type := self parentBehaviouralEntity.
		  s
			  nextPutAll: type mooseNameWithDots;
			  nextPut: $.;
			  nextPutAll: 'this' ]
]
