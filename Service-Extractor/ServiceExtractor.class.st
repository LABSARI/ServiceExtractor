"
A service extrator. It takes a famix method and give all (available at static time) entities needed to execute that service.
"
Class {
	#name : #ServiceExtractor,
	#superclass : #Object,
	#instVars : [
		'methodToExtract',
		'slicedClasses',
		'callGraph'
	],
	#category : #'Service-Extractor'
}
