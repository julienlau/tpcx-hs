name := "TPCx-HS-master_Spark"

version := "2.1.0"

scalaVersion := "2.10.7"
val sparkVersion = "1.6.3"

libraryDependencies += "org.apache.spark" % "spark-sql_2.10" % sparkVersion

libraryDependencies += "org.apache.spark" %% "spark-core" % sparkVersion excludeAll(
    ExclusionRule(organization = "com.twitter"),
    ExclusionRule(organization = "org.apache.spark", name = "spark-network-common_2.10"),
    ExclusionRule(organization = "org.apache.hadoop", name = "hadoop-client"),
    ExclusionRule(organization = "org.apache.hadoop", name = "hadoop-hdfs"),
    ExclusionRule(organization = "org.tachyonproject", name = "tachyon-client"),
    ExclusionRule(organization = "commons-beanutils", name = "commons-beanutils"),
    ExclusionRule(organization = "commons-collections", name = "commons-collections"),
    ExclusionRule(organization = "org.apache.hadoop", name = "hadoop-yarn-api"),
    ExclusionRule(organization = "org.apache.hadoop", name = "hadoop-yarn-common"),
    ExclusionRule(organization = "org.apache.curator", name = "curator-recipes")
  )

libraryDependencies += "org.apache.spark" %% "spark-network-common" % sparkVersion exclude("com.google.guava", "guava")
libraryDependencies += "org.apache.spark" %% "spark-graphx" % sparkVersion
libraryDependencies += "com.typesafe.scala-logging" %% "scala-logging-slf4j" % "2.1.2"
libraryDependencies += "org.apache.hadoop" % "hadoop-client" % "2.2.0" exclude("com.google.guava", "guava")
libraryDependencies += "com.google.guava" % "guava" % "14.0.1"
libraryDependencies += "org.json4s" %% "json4s-native" % "3.2.11"
libraryDependencies += "org.json4s" %% "json4s-ext" % "3.2.11"
libraryDependencies += "commons-codec" % "commons-codec" % "1.10"

test in assembly := {}

assemblyMergeStrategy in assembly := {
  case m if m.toLowerCase.startsWith("meta-inf")            => MergeStrategy.discard
  case m if m.toLowerCase.endsWith("manifest.mf")           => MergeStrategy.discard
  case m if m.toLowerCase.matches("log4j.properties")       => MergeStrategy.discard
  case m if m.toLowerCase.matches("gelf-log4j.properties")  => MergeStrategy.discard
  case PathList(ps @ _*) if ps.last endsWith ".html"        => MergeStrategy.first
  case PathList("org", "apache", "spark", "unused", "UnusedStubClass.class", xs @ _*) => MergeStrategy.first
  case PathList("javax", "inject", xs @ _*)                 => MergeStrategy.last
  case PathList("javax", "servlet", xs @ _*)                => MergeStrategy.last
  case PathList("javax", "activation", xs @ _*)             => MergeStrategy.last
  case PathList("com", "esotericsoftware", xs @ _*)         => MergeStrategy.last
  case PathList("com", "google", xs @ _*)                   => MergeStrategy.last
  case PathList("commons-beanutils", xs @ _*)               => MergeStrategy.last
  case PathList("org", "apache", xs @ _*)                   => MergeStrategy.last
  case "application.conf"                                   => MergeStrategy.concat
  case x =>
    val oldStrategy = (assemblyMergeStrategy in assembly).value
    oldStrategy(x)
}
