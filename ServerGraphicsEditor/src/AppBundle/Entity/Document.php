<?php

namespace AppBundle\Entity;

use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Validator\Constraints as Assert;
use Symfony\Component\HttpFoundation\File\UploadedFile;
use Symfony\Component\HttpFoundation\File\File;
/**
 * @ORM\Entity
 * @ORM\Table(name="document")
 */
class Document
{
    /**
     * @ORM\Column(type="integer", nullable=false)
     * @ORM\Id
     * @ORM\GeneratedValue(strategy="AUTO")
     */
    private $id;

    /**
     * @ORM\Column(type="string", length=25)
     */
    private $name;

    /**
     * @ORM\ManyToOne(targetEntity="User")
     * @ORM\JoinColumn(name="author_id", referencedColumnName="id", onDelete="CASCADE")
     */
    private $author;

    /**
     * @ORM\Column(type="string", length=100)
     */
    private $imagePath;

    /**
     * @ORM\Column(type="string", length=100)
     */
    private $documentPath;

    /**
     * @Assert\File(
     *     maxSize = "5M",
     *     maxSizeMessage = "The maxmimum allowed file size is 5MB."
     * )
     */
    private $image;

    /**
     * Sets image.
     *
     * @param UploadedFile $file
     */
    public function setImage(UploadedFile $file = null)
    {
        $this->image = $file;
    }
    /**
     * Get file.
     *
     * @return UploadedFile
     */
    public function getImage()
    {
        return $this->image;
    }

    /**
     * @Assert\File(
     *     maxSize = "30M",
     *     maxSizeMessage = "The maxmimum allowed file size is 30MB."
     * )
     */
    private $document;

    /**
     * Sets image.
     *
     * @param UploadedFile $file
     */
    public function setDocument(File $file = null)
    {
        $this->document = $file;
    }
    /**
     * Get file.
     *
     * @return File
     */
    public function getDocument()
    {
        return $this->document;
    }

    public function getWebImagePath()
    {
        return null === $this->getImagePath()
            ? null
            : '/'.$this->getUploadDir().$this->getImagePath();
    }

    public function getWebDocumentPath()
    {
        return null === $this->getDocumentPath()
            ? null
            : '/'.$this->getUploadDir().$this->getDocumentPath();
    }

    /**
     * @return string
     */
    public function getUploadDir()
    {
        $directory = "uploads/".$this->author->getUsername()."/";
        if (!file_exists($directory))
        {
            mkdir($directory, 0777);
        }
        return $directory;
    }

    function generateRandomString($length)
    {
        return substr(str_shuffle(str_repeat($x='0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ', ceil($length/strlen($x)) )),1,$length);
    }

    public function generateFileName()
    {
        while (file_exists($this->getUploadDir().$this->imagePath))
        {
            $suffix = $this->generateRandomString(3);
            $this->setImagePath($this->getName() . $suffix . '.jpg');
            $this->setDocumentPath($this->getName() . $suffix . '.drg');
        }
    }

    /**
     * Called after entity persistence
     *
     * @ORM\PostPersist()
     * @ORM\PostUpdate()
     */
    public function upload()
    {
        if (null === $this->image || null === $this->document) {
            return;
        }

        $this->setImagePath($this->getName().'.jpg');
        $this->setDocumentPath($this->getName().'.drg');


        $this->generateFileName();

        $this->getImage()->move(
            $this->getUploadDir(),
            $this->getImagePath()
        );
        $this->getDocument()->move(
            $this->getUploadDir(),
            $this->getDocumentPath()
        );

        $this->setDocument(null);
        $this->setImage(null);
    }

    /**
     * Get id
     *
     * @return integer
     */
    public function getId()
    {
        return $this->id;
    }

    /**
     * Set name
     *
     * @param string $name
     *
     * @return Document
     */
    public function setName($name)
    {
        $this->name = $name;

        return $this;
    }

    /**
     * Get name
     *
     * @return string
     */
    public function getName()
    {
        return $this->name;
    }

    /**
     * Set imagePath
     *
     * @param string $imagePath
     *
     * @return Document
     */
    public function setImagePath($imagePath)
    {
        $this->imagePath = $imagePath;

        return $this;
    }

    /**
     * Get imagePath
     *
     * @return string
     */
    public function getImagePath()
    {
        return $this->imagePath;
    }

    /**
     * Set documentPath
     *
     * @param string $documentPath
     *
     * @return Document
     */
    public function setDocumentPath($documentPath)
    {
        $this->documentPath = $documentPath;

        return $this;
    }

    /**
     * Get documentPath
     *
     * @return string
     */
    public function getDocumentPath()
    {
        return $this->documentPath;
    }

    /**
     * Set author
     *
     * @param \AppBundle\Entity\User $author
     *
     * @return Document
     */
    public function setAuthor(\AppBundle\Entity\User $author = null)
    {
        $this->author = $author;

        return $this;
    }

    /**
     * Get author
     *
     * @return \AppBundle\Entity\User
     */
    public function getAuthor()
    {
        return $this->author;
    }
}
