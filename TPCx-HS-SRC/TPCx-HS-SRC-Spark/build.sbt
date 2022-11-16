name := "TPCx-HS-master_Spark"

version := "2.2.1"

//scalaVersion := "2.11.12"
scalaVersion := "2.12.17"
val sparkVersion = "3.3.1"
val hadoopVersion = "3.3.4"

libraryDependencies += "org.apache.spark" %% "spark-core" % sparkVersion % "provided" excludeAll(ExclusionRule(organization = "com.amazonaws"))
libraryDependencies += "org.apache.spark" %% "spark-sql" % sparkVersion % "provided" excludeAll(ExclusionRule(organization = "com.amazonaws"))

// spark on S3
// Be aware : Filesystems jars bundled in the user-jar/fatjar are not used.
// Filesystems jars must present either in /lib or /plugins or /jars
// to avoid error : java.lang.ClassNotFoundException: Class org.apache.hadoop.fs.s3a.S3AFileSystem
libraryDependencies += "org.apache.hadoop" % "hadoop-client" % hadoopVersion % "provided"
libraryDependencies += "org.apache.hadoop" % "hadoop-aws" % hadoopVersion % "provided"

artifactName := { (sv: ScalaVersion, module: ModuleID, artifact: Artifact) =>
  artifact.name + "_" + sv.binary + "-" + sparkVersion + "_" + module.revision + "." + artifact.extension
}
assemblyJarName in assembly := s"${name.value}_${scalaBinaryVersion.value}-${sparkVersion}_${version.value}.jar"


test in assembly := {}

assemblyMergeStrategy in assembly := {
  case PathList("org", "apache", "parquet", xs @ _*)             => MergeStrategy.last
  case PathList("com", "sun", "research", "ws", "wadl", xs @ _*) => MergeStrategy.last // jersey-server
  case PathList("org","aopalliance", xs @ _*)                    => MergeStrategy.last
  case PathList("javax", "inject", xs @ _*)                      => MergeStrategy.last
  case PathList("javax", "servlet", xs @ _*)                     => MergeStrategy.last
  case PathList("javax", "activation", xs @ _*)                  => MergeStrategy.last
  case PathList("org", "apache", "hadoop", xs @ _*)              => MergeStrategy.last
  case PathList("com", "fasterxml", "jackson", _, xs @ _*)       => MergeStrategy.last
  case PathList("org", "apache", xs @ _*)                        => MergeStrategy.last
  case PathList("com", "google", xs @ _*)                        => MergeStrategy.last
  case PathList("com", "esotericsoftware", xs @ _*)              => MergeStrategy.last
  case PathList("com", "codahale", xs @ _*)                      => MergeStrategy.last
  case PathList("com", "yammer", xs @ _*)                        => MergeStrategy.last
  case PathList("org", "slf4j", xs @ _*)                        => MergeStrategy.rename
  case PathList("shaded", "parquet", "it", xs @ _*)              => MergeStrategy.first
  case PathList("javax", xs @ _*)                                => MergeStrategy.first
  case PathList("jersey", xs @ _*)                               => MergeStrategy.last
  case "about.html"                                          => MergeStrategy.rename
  case m if m.toLowerCase.startsWith("meta-inf")             => MergeStrategy.discard
  case m if m.toLowerCase.endsWith("manifest.mf")            => MergeStrategy.discard
  case m if m.toLowerCase.endsWith("notice")                 => MergeStrategy.discard
  case m if m.toLowerCase.endsWith("license")                => MergeStrategy.discard
  case m if m.toLowerCase.endsWith("public-suffix-list.txt") => MergeStrategy.first
  case m if m.toLowerCase.startsWith("module-info")          => MergeStrategy.first
  case m if m.toLowerCase.matches("properties.dtd")          => MergeStrategy.first
  case m if m.toLowerCase.startsWith("propertylist")         => MergeStrategy.first
  case m if m.toLowerCase.startsWith("webapps")              => MergeStrategy.first
  case m if m.toLowerCase.matches("log4j.properties")        => MergeStrategy.last
  case m if m.toLowerCase.matches("gelf-log4j.properties")   => MergeStrategy.last
  case "plugin.properties"                                   => MergeStrategy.last
  case PathList(ps @ _*) if ps.last endsWith ".conf"         => MergeStrategy.first
  case PathList(ps @ _*) if ps.last endsWith ".html"         => MergeStrategy.last
  case PathList(ps @ _*) if ps.last endsWith ".xml"          => MergeStrategy.last
  case PathList(ps @ _*) if ps.last endsWith ".properties"   => MergeStrategy.last
  case PathList(ps @ _*) if ps.last startsWith "aws-java-sdk"=> MergeStrategy.singleOrError
  //case _ => MergeStrategy.singleOrError
  case x =>
    val oldStrategy = (assemblyMergeStrategy in assembly).value
    oldStrategy(x)
}
